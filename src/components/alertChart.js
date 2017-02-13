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

import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import {fetchDashboardData} from '../redux/actions/apiActions';

class AlertChart extends React.Component {
    constructor(props) {
        super(props);
        this.state = {data: []};            
    }

    fetchData(alerts) {
        this.props.fetchDashboardData(14, localStorage.getItem('key'))
            .then(res => {
                this.setState({
                    data: this.convertKey(this.props.dashboardData),
                });
                alerts.addData(this.state.data);
            });
    }

    convertKey(data){
        let xy = [];
        for (var i = 0; i < data.length; ++i) {
            xy.push({
                x: parseInt(data[i].date),
                y: parseInt(data[i].counter),
            })
        }
        return xy;
    }
    componentDidMount() {
    (() => {
        var chart = new Rubix('#single-series-column-chart', {
          height: 300,
          title: 'Two Week\'s Data',
          subtitle: 'Registered User',
          titleColor: '#ffffff',
          subtitleColor: '#ffffff',
          axis: {
            x: {
              type: 'linear',
              tickFormat: 'd'
            },
            y: {
              type: 'linear',
              tickFormat: 'd'
            }
          },
          tooltip: {
            color: '#D71F4B',
            format: {
                y: '.0f'
            }
          },
            margin: {
                left: 50
            },
            grouped: false,
            show_markers: true
        });

        var fruits = chart.column_series({
            name: 'Users',
            color: '#D71F4B'
        });

        this.fetchData(fruits);

    })();
    }

    render() {
        return (
            <Row>
                <Col xs={12}>
                    <div id='single-series-column-chart' className='rubix-chart'></div>
                </Col>
            </Row>
        );
    }
}



AlertChart.propTypes = {
    fetchDashboardData : React.PropTypes.func.isRequired
}

const mapStateToProps = (state, ownProps) => {
    return {
        dashboardData: state.dashboardReducer.dashboardData,
    }
};

export default connect(mapStateToProps, { fetchDashboardData })(AlertChart);
