import React from 'react';
import classNames from 'classnames';
import { IndexRoute, Route } from 'react-router';

import { Grid, Row, Col, MainContainer } from '@sketchpixy/rubix';

/* Common Components */

import Sidebar from './common/sidebar';
import Header from './common/header';
import Footer from './common/footer';

/* Pages */

import Home from './routes/Home';
import UserEdit from './routes/UserEditForm';
import UserList from './routes/UserList';

//import Lock from './routes/Lock';
//import Login from './routes/Login';
//import Signup from './routes/Signup';


class App extends React.Component {
    render() {
        return (
            <MainContainer {...this.props}>
                <Sidebar />
                <Header />
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
    <Route component={App}>
        <Route path='/home' component={Home} />
        <Route path='tables/datatables' component={UserList} />
        <Route path='user/edit(/:id)' component={UserEdit} />
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
        <Route path='/' component={App} />

        <Route path='/ltr'>
            {combinedRoutes}
        </Route>
        <Route path='/rtl'>
            {combinedRoutes}
        </Route>
    </Route>
);
