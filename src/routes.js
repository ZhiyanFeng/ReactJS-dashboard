import React from 'react';
import classNames from 'classnames';
import { IndexRoute, Route } from 'react-router';
import { withRouter  } from 'react-router';

import { Grid, Row, Col, MainContainer } from '@sketchpixy/rubix';

/* Common Components */

import Sidebar from './common/sidebar';
import Header from './common/header';
import Footer from './common/footer';

/* Pages */

import UserList from './routes/UserList';
import adminClaim from './routes/adminClaim';
import LocationList from './routes/LocationList';
import ChannelList from './routes/ChannelList';
import LocationDetails from './routes/LocationDetails';
import Dashboard from './routes/Dashboard';
import LoginPage from './components/login/login';
import AddChannel from './components/addChannelForm';
import AddRegionChannel from './components/addRegionChannelForm';
import Userdetail from './routes/Userdetail';

class App extends React.Component {

    componentWillMount(){
        if(!localStorage.getItem('key')){
            this.props.router.push('/ltr/login');
        };
    }   

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
        <Route path='adminClaim' component={adminClaim} />
        <Route path='tables/locationList' component={LocationList} />
        <Route path='user/edit(/:id)' component={Userdetail} />
        <Route path='channel/add' component={AddChannel} />
        <Route path='channel/addRegionChannel' component={AddRegionChannel} />
        <Route path='channel/list' component={ChannelList} />
        <Route path='location/edit(/:id)' component={LocationDetails} />
    </Route>
);

/**
 *  * No Sidebar, Header or Footer. Only the Body is rendered.
 *   */

const basicRoutes = (
    <Route>
        <Route path='login' component={LoginPage} />
    </Route>
);

const combinedRoutes = (
    <Route>
        <Route>
            {routes}
        </Route>
        <Route>
            {basicRoutes}
        </Route>
    </Route>
);
//const combinedRoutes = (
//    <Route>
//        {routes}
//    </Route>
//
//);

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
