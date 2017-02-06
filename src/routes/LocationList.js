import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import _ from 'lodash';

import {
    Row,
    Col,
    Grid,
    Panel,
    Table,
    PanelBody,
    PanelHeader,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

import {searchLocations} from '../redux/actions/apiActions';
import LocationListElement from '../components/LocationListElement';

class  DatatableComponent extends React.Component {


    componentDidMount() {
        $(ReactDOM.findDOMNode(this.example))
            .addClass('nowrap')
        //.dataTable({
        //       columnDefs: [
        //           { targets: [-1, -3], className: 'dt-body-left' }
        //       ],
        //   });
    }

    updateSearch(){
        this.searchLocations(this.refs.searchInput.value, localStorage.getItem('key'));
    }

    searchLocations(query="", key){
        this.props.searchLocations(query, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        )
    }

    render() {
        return (
            <div>
                <div>
                    <input ref="searchInput" type="text" id="serarchBox"/>
                    <button id="serachButton" onClick={(e)=>{this.updateSearch();}}>Search</button>
                </div>

                <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Formatted Address</th>
                            <th>City</th>
                            <th>Location Name</th>
                            <th>Member Count</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.props.locations.map((location, index) =>{
                            return(
                                <LocationListElement key={location.id} location={location}/>
                            );
                        })}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>Formatted Address</th>
                            <th>City</th>
                            <th>Location Name</th>
                            <th>Member Count</th>
                        </tr>
                    </tfoot>
                </Table>
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

