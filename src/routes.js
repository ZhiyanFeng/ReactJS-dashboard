import React from 'react';
import classNames from 'classnames';
import { IndexRoute, Route } from 'react-router';

import { Grid, Row, Col, MainContainer } from '@sketchpixy/rubix';

/* Common Components */

import Sidebar from './common/sidebar';
import Header from './common/header';
import Footer from './common/footer';

/* Pages */

import UserList from './routes/UserList';
import LocationList from './routes/LocationList';
import LocationDetails from './routes/LocationDetails';
import Dashboard from './routes/Dashboard';
import LoginPage from './components/login/login';
import AddChannel from './components/addChannelForm';
import Userdetail from './routes/Userdetail';
import LineSeries from './routes/LineSeries';
import AreaSeries from './routes/AreaSeries';
import BarColSeries from './routes/BarColSeries';
import MixedSeries from './routes/MixedSeries';
import PieDonutSeries from './routes/PieDonutSeries';
//import userSubscriptionList from './components/userSubscriptionList';

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
// <Route path='userSubscriptionList' component={userSubscriptionList} />
//<Route path='charts/rubix/line' component={LineSeries} />
//       <Route path='charts/rubix/area' component={AreaSeries} />
//       <Route path='charts/rubix/barcol' component={BarColSeries} />
//       <Route path='charts/rubix/mixed' component={MixedSeries} />
//       <Route path='charts/rubix/piedonut' component={PieDonutSeries} />

const routes = (
    <Route path='admin' component={App}>
        <Route path='dashboard' component={Dashboard} />
        <Route path='tables/userList' component={UserList} />
        <Route path='tables/locationList' component={LocationList} />
        <Route path='user/edit(/:id)' component={Userdetail} />
        <Route path='channel/add' component={AddChannel} />
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
