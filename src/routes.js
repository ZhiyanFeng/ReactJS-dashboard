import React from 'react';
import classNames from 'classnames';
import { IndexRoute, Route } from 'react-router';

import { Grid, Row, Col, MainContainer } from '@sketchpixy/rubix';

/* Common Components */

import Sidebar from './common/sidebar';
import Header from './common/header';
import Footer from './common/footer';

/* Pages */

import UserEdit from './components/UserEditForm';
import UserList from './routes/UserList';
import LocationList from './routes/LocationList';
import Dashboard from './routes/Dashboard';
import LoginPage from './components/login/login';
import XEditable from './routes/XEditable';

//import Lock from './routes/Lock';
//import Login from './routes/Login';
//import Signup from './routes/Signup';


class App extends React.Component {
    render() {
        return (
            <MainContainer {...this.props}>
                <Sidebar />
                <Header {...this.props}/>
                <div id='body'>
                    <Grid>
                        <Row>
                            <Col xs={12}>
                                {this.props.children}
                            </Col>
                        </Row>
                    </Grid>
                </div>
                <Footer />
            </MainContainer>
        );
    }
}

const routes = (
    <Route path='admin' component={App}>
        <Route path='dashboard' component={Dashboard} />
        <Route path='tables/userList' component={UserList} />
        <Route path='tables/locationList' component={LocationList} />
        <Route path='user/edit(/:id)' component={XEditable} />
    </Route>
);

/**
*  * No Sidebar, Header or Footer. Only the Body is rendered.
    *   */

const combinedRoutes = (
    <Route>
        {routes}
    </Route>

);

export default (
    <Route>
        <Route path='/' component={LoginPage} />
        <Route path='/ltr'>
            {combinedRoutes}
        </Route>
        <Route path='/rtl'>
            {combinedRoutes}
        </Route>
    </Route>
);
