import React from 'react';

import {
  Row,
  Tab,
  Col,
  Nav,
  Icon,
  Grid,
  Form,
  Table,
  Label,
  Panel,
  Button,
  NavItem,
  Checkbox,
  Progress,
  PanelBody,
  FormGroup,
  PanelLeft,
  isBrowser,
  InputGroup,
  LoremIpsum,
  PanelRight,
  PanelHeader,
  FormControl,
  PanelContainer,
  PanelTabContainer,
} from '@sketchpixy/rubix';

import {fetchDashboardData} from '../redux/actions/apiActions';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import RevenuePanel from '../components/revenuePanel';
import AlertChart from '../components/alertChart';


class Dashboard extends React.Component {
    constructor(props) {
        super(props);
        this.state = {};
    }

    componentWillMount (){
        this.props.fetchDashboardData(14, localStorage.getItem('key'))
            .then(res => {
                let twoWeekSum = this.sumTwoWeekCount(this.props.dashboardData);
                this.setState({
                    data: this.props.dashboardData,
                    countForToday: this.props.dashboardData[0].counter,
                    twoWeekCount: twoWeekSum,
                });
            });
    }

    sumTwoWeekCount(data){
        return data.reduce(function(a, b){
            return a + parseInt(b.counter);
        }, 0);
    }

    render() {
        return (
            <div className='dashboard'>
                <Row>
                    <Col sm={12}>
                        <PanelTabContainer id='dashboard-main' defaultActiveKey="demographics">
                            <Panel horizontal className='force-collapse'>
                                <PanelLeft className='bg-lightgreen fg-white panel-sm-2'>
                                    <RevenuePanel count={this.state.countForToday} twoWeekCount={this.state.twoWeekCount}/>
                                </PanelLeft>
                                <PanelRight className='bg-green fg-green panel-sm-4'>
                                    <Grid>
                                        <AlertChart />
                                    </Grid>
                                </PanelRight>
                            </Panel>
                        </PanelTabContainer>
                    </Col>
                </Row>

                <Row>
                    <Col sm={12}>
                        <div style={{height: 450}} className='rubix-panel-container-with-controls' id='reflect-test'>

                        </div>
                    </Col>
                </Row>
            </div>
        );
    }
}

Dashboard.propTypes = {
    fetchDashboardData : React.PropTypes.func.isRequired
}

const mapStateToProps = (state, ownProps) => {
    return {
        dashboardData: state.dashboardReducer.dashboardData,
    }
};

export default connect(mapStateToProps, {fetchDashboardData})(Dashboard);
