import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import { Link, withRouter } from 'react-router';
import { Pagination } from "react-bootstrap";
import {push, routeActions}  from "react-router-redux";

import {
    Row,
    Col,
    Grid,
    Panel,
    Icon,
    Table,
    PanelBody,
    PanelHeader,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

import {searchLocations} from '../redux/actions/apiActions';
import WorkLocationListElement from '../components/WorkLocationListElement';
import { searchWorkLocations} from '../redux/actions/apiActions';

class  DatatableComponent extends React.Component {
    constructor(props){
        super(props);
        this.state ={
            locations:[],
        }
    }

    componentDidMount () {
        this.props.searchWorkLocations(this.props.user_id, localStorage.getItem('key'))
            .then(res => {
                this.setState({locations: res});
            });
    }

    render() {
        return (
            <div>
                <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Formatted Address</th>
                            <th>City</th>
                            <th>Location Name</th>
                            <th>Swift code</th>
                            <th>Is admin</th>
                            <th>Text</th>
                            <th>Change admin</th>
                            <th>Send message</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.state.locations.map((location, index) =>{
                                return(
                                    <WorkLocationListElement key={location.id} user_id = {this.props.user_id} location={location}/>
                                );
                        })}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>Formatted Address</th>
                            <th>City</th>
                            <th>Location Name</th>
                            <th>Swift code</th>
                            <th>Is admin</th>
                            <th>Text</th>
                            <th>Change admin</th>
                            <th>Send message</th>
                        </tr>
                    </tfoot>
                </Table>
            </div>
        );
    }
}

//@connect((state) => state.locationReducer)
class WorkLocationList extends React.Component {
    render() {
        return (
            <Row>
                <Col xs={12}>
                    <PanelContainer>
                        <Panel>
                            <PanelBody>
                                <Grid>
                                    <Row>
                                        <Col xs={12}>
                                            <DatatableComponent {...this.props}/>
                                            <br/>
                                        </Col>
                                    </Row>
                                </Grid>
                            </PanelBody>
                        </Panel>
                    </PanelContainer>
                </Col>
            </Row>
        );
    }
}

WorkLocationList.Types = {
    searchWorkLocations: React.PropTypes.func.isRequired
}

const mapStateToProps = (state) => {
    return {
        locations: state.locationReducer.locations,
    }
};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchWorkLocations: searchWorkLocations,
        }, dispatch)
    }
};

export default connect(mapStateToProps, myDispatch)(WorkLocationList);

