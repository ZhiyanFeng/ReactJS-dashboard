import React from 'react';
import ReactDOM from 'react-dom';
import ReactDOMServer from 'react-dom/server';
import { Router, match, RouterContext, applyRouterMiddleware,
         hashHistory, browserHistory } from 'react-router';
import { AppContainer } from 'react-hot-loader';
import useScroll from '@sketchpixy/react-router-scroll';

import { Provider } from 'react-redux';
//import { createStore, combineReducers, applyMiddleware as origApplyMiddleware, compose } from 'redux';
import { createStore, combineReducers, applyMiddleware, compose } from 'redux';
import { syncHistoryWithStore, routerReducer, routerMiddleware } from 'react-router-redux';
import thunk from 'redux-thunk';

import { FetchData, fetchDataOnServer, reducer as fetching } from '@sketchpixy/redux-fetch-data';
import { flattenComponents } from '@sketchpixy/redux-fetch-data/lib/utils';

import onRouterSetup from './onRouterSetup';
import onRouterUpdate from './onRouterUpdate';
import checkScroll from './checkScroll';

import isBrowser from '../isBrowser';
import { reducer as formReducer } from 'redux-form';
import createLogger from 'redux-logger';
import setAuthorizationToken from '../redux/utils/setAuthorizationToken';
import jwt from 'jsonwebtoken';
import {setCurrentUser} from '../redux/actions/authActions';

if (isBrowser()) {
  onRouterSetup();
}

class WrapperComponent extends React.Component {
  render() {
    return this.props.children;
  }
}

var isRouterSet = false, history, reducer, store, routes;

export function setupReducers(reducers) {
  reducer = combineReducers({
      userReducer: reducers.userReducer,
      storePhotoReducer: reducers.storePhotoReducer,
      activeUserReducer: reducers.activeUserReducer,
      authReducer: reducers.authReducer,
      locationReducer: reducers.locationReducer,
      channelReducer: reducers.channelReducer,
      locationDetailReducer: reducers.locationDetailReducer,
      activeUserLatestContentsReducer: reducers.activeUserLatestContentsReducer,
      dashboardReducer: reducers.dashboardReducer,
      adminClaimReducer: reducers.adminClaimReducer,
      form: formReducer,
      fetching: fetching,
      routing: routerReducer,
  });
}

export function replaceReducers(reducers) {
    setupReducers(reducers);
    store.replaceReducer(reducer);
}

function preloadedData() {
    return document.getElementById('preloadedData');
}

function getData() {
    let element = preloadedData();
    return element ? JSON.parse(element.textContent) : '';
}

var middlewares = [thunk, createLogger()];

function createStoreWithMiddleware() {
    return compose(
        applyMiddleware(...middlewares),
        window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__ && isBrowser() && typeof window.devToolsExtension !== 'undefined' ? window.devToolsExtension() : f => f
    )(createStore);
}

export function createReduxStore(initialState) {
    let store = (createStoreWithMiddleware())(reducer, initialState);
    if(localStorage.jwtToken){
        setAuthorizationToken(localStorage.jwtToken);
        store.dispatch(setCurrentUser(jwt.decode(localStorage.jwtToken)));
    }
    return store;
}

function onFetchData(props) {
    // onRouterUpdate();
    var container = document.getElementById('container');
    if (container) {
        container.scrollTop = 0;
    }
    return <FetchData {...props} />;
}

export default function render(Component, onRender) {
    if (!onRender) onRender = function() {};

    if (isBrowser()) {
        // in browser

        if (!isRouterSet) {
            isRouterSet = true;
            history = (Modernizr.history
                ? browserHistory
                : hashHistory);

            const initialState = getData();
            store = createReduxStore(initialState);
            history = syncHistoryWithStore(history, store);

            routes = (
                <Provider store={store} key='provider'>
                    <Router history={history}
                        render={onFetchData}>
                        {Component}
                    </Router>
                </Provider>
            );
        }

        ReactDOM.render(<AppContainer><WrapperComponent>{routes}</WrapperComponent></AppContainer>,
            document.getElementById('app-container'),
            onRender);
    }
}

export function renderHTMLString(routes, req, callback) {
    const store = createReduxStore();
    // in server
    match({ routes, location: req.url}, (error, redirectLocation, renderProps) => {
        if (!renderProps) {
            callback('renderProps not defined!');
            return;
        }

        fetchDataOnServer(renderProps, store).then(() => {
            if (error) {
                callback(error);
            } else if (redirectLocation) {
                callback(null, redirectLocation);
            } else if (renderProps) {
                callback(null, null, {
                    content: ReactDOMServer.renderToString(
                        <AppContainer>
                            <Provider store={store} key='provider'>
                                <RouterContext {...renderProps} />
                            </Provider>
                        </AppContainer>
                    ),
                    data: store.getState()
                });
            } else {
                callback({
                    message: 'Not found'
                });
            }
        });
    });
}
