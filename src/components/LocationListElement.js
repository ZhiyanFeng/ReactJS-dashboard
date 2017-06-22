import React from 'react';
import { Link } from 'react-router';
import {Button, Glyphicon} from 'react-bootstrap';
import { connect  } from 'react-redux';
import EditableCell from './EditableCell.js';
import { updateLocation } from "../redux/actions/apiActions";
import { bindActionCreators } from "redux";

class LocationListElement extends React.Component{
    constructor(props){
        super(props);
        this.modalDeleteShow = this.modalDeleteShow.bind(this);
        this.updateLocation = this.updateLocation.bind(this);
        this.getParams = this.getParams.bind(this);
    }

    modalDeleteShow(event){
        const locationId = Number(event.target.dataset.id);
        const phoneNumber = event.target.dataset.phone_number;
        this.props.dispatch({
            type: 'location.modalDelete',
            id: locationId,
            phone: phoneNumber,  
        })

    }
    
    getParams(event){
        let params = {};
        let id = event.target.dataset.id;
        if(event.target.dataset.name !== this.refs.location_name.getValue()){
            params['location_name']= this.refs.location_name.getValue(); 
            this.refs.location_name.setDefault();
        }

        if(event.target.dataset.address !== this.refs.address.getValue()){
            params['formatted_address'] = this.refs.address.getValue(); 
            this.refs.address.setDefault();
        }
        
        if (!$.isEmptyObject(params)){
            this.updateLocation(id, params);
        }
    }

    updateLocation(id, params){
        let key = localStorage.getItem("key");
        this.props.updateLocation(id, params, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        );
    } 

    render()
    {
        const location = this.props.location;
        return (
            <tr> 
                <td>{location.id}</td>
                <EditableCell ref="address" data={location.formatted_address} /> 
                <td>{location.city}</td>
                <EditableCell ref="location_name" data={location.location_name} /> 
                <td>{location.member_count}</td>
                <td>{location.created_at}</td>
                <td>
                    <Button type="button" className="btn btn-success" bsSize="small" data-id={location.id} data-name={location.location_name} 
                        data-address={location.formatted_address} onClick={this.getParams}>Edit <Glyphicon glyph="ok"/></Button>
                </td>
                <td>
                    <Link to={'/ltr/admin/location/edit/' + location.id}>
                        <Button type="button" className="btn btn-primary" bsSize="small">Details <Glyphicon glyph="edit"/></Button>
                    </Link>
                </td>
                <td>
                    <Button type="button" className="btn btn-danger" bsSize="small" data-id={location.id} data-phone_number={location.phone_number} onClick={this.modalDeleteShow}>Delete <Glyphicon glyph="remove-circle"/></Button>
                </td>
            </tr>
        );
    }
}

LocationListElement.propTypes = {
    updateLocation: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch) => {
    return {
        dispatch,
        ...bindActionCreators({
            updateLocation: updateLocation,
        }, dispatch)
    };
};

export default connect(null, myDispatch)(LocationListElement);
