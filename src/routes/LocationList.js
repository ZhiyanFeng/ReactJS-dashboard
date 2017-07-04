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
import LocationListElement from '../components/LocationListElement';

class  DatatableComponent extends React.Component {
    constructor(props){
        super(props);
        this.updateSearch = this.updateSearch.bind(this);
        this._handleKeyPress = this._handleKeyPress.bind(this);
        this.changePage = this.changePage.bind(this);
    }

    updateSearch(){
        this.searchLocations(this.refs.searchInput.value, localStorage.getItem('key'));
    }

    _handleKeyPress(e) {
        if (e.key === 'Enter') {
            this.updateSearch();
        }
    }

    searchLocations(query="", key){
        this.props.searchLocations(query, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        )
    }

    changePage(page){
        this.props.router.push(`/ltr/admin/tables/locationList?page=${page}`);
    }

    render() {
        //set the pagination variables
        const per_page =10;
        const pages = Math.ceil(this.props.locations.length / per_page);
        const current_page = this.props.page;
        const start_offset = (current_page -1) * per_page;
        let start_count = 0;
        return (
            <div>
                <div>
                    <div>
                        <input ref="searchInput" type="text" id="serarchBox" onKeyPress={this._handleKeyPress}/>
                        <button id="serachButton" onClick={(e)=>{this.updateSearch();}}>Search</button>
                    </div>
                </div>

                <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Formatted Address</th>
                            <th>City</th>
                            <th>Location Name</th>
                            <th>Swift code</th>
                            <th>Member Count</th>
                            <th>Created at</th>
                            <th>Details</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.props.locations.map((location, index) =>{
                            if(index >= start_offset && start_count < per_page){
                                start_count++;
                                return(
                                    <LocationListElement key={location.id} location={location}/>
                                );
                            }
                        })}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>Formatted Address</th>
                            <th>City</th>
                            <th>Location Name</th>
                            <th>Swift code</th>
                            <th>Member Count</th>
                            <th>Created at</th>
                            <th>Details</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>
                    </tfoot>
                </Table>
                <div className="text-center">
                    <Pagination className="users-pagination text-center" bsSize="medium"
                        maxButtons={10} first last next prev boundaryLinks
                        items={pages} activePage={current_page} onSelect={this.changePage}/>
                </div>
                <locationDelete/>
            </div>
        );
    }
}

//@connect((state) => state.locationReducer)
class LocationList extends React.Component {
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

LocationList.propTypes = {
    searchLocations: React.PropTypes.func.isRequired
}

const mapStateToProps = (state) => {
    return {
        locations: state.locationReducer.locations,
        page: Number(state.routing.locationBeforeTransitions.query.page) || 1,
    }
};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchLocations: searchLocations,
        }, dispatch)
    }
};

export default connect(mapStateToProps, myDispatch)(LocationList);

