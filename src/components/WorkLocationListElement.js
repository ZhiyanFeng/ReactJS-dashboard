import React from 'react';
import { Link } from 'react-router';
import {Button, Glyphicon} from 'react-bootstrap';
import { connect  } from 'react-redux';
import EditableCell from './EditableCell.js';
import { updateUser, pushSNS } from "../redux/actions/apiActions";
import { bindActionCreators } from "redux";

class LocationListElement extends React.Component{
    constructor(props){
        super(props);
        this.state = {
            is_admin : this.props.location.is_admin ? 'on' : '',
            key : localStorage.getItem("key")
        }
        this.modalDeleteShow = this.modalDeleteShow.bind(this);
        this.updateUser = this.updateUser.bind(this);
        this.getParams = this.getParams.bind(this);
        this.pushSNS = this.pushSNS.bind(this);
    }

    modalDeleteShow(event){
        const locationId = Number(event.target.dataset.location_id);
        const phoneNumber = event.target.dataset.phone_number;
        this.props.dispatch({
            type: 'location.modalDelete',
            id: locationId,
            phone: phoneNumber,  
        })

    }

    getParams(event){
        let params = {};
        let location_id = event.target.dataset.location_id;
        let user_id = this.props.user_id;
        let new_isAdmin = this.refs.is_admin.getValue();
        if(this.state.is_admin !== new_isAdmin){
            params['is_admin'] = new_isAdmin === 'on' ? 'true' : 'false'; 
            this.setState({is_admin: new_isAdmin});
            params['location_id'] = location_id; 
            this.refs.is_admin.setDefault();
            this.updateUser(user_id, params);
        }

        if(this.refs.sns_text.getValue()){
            params['sns_text'] == this.refs.sns_text.getValue();
            this.pushSNS(user_id, params);
        }
        //if (!$.isEmptyObject(params)){
        //}
    }

    pushSNS(userId, params){
        this.props.pushSNS(id, params, this.state.key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        );
    }

    updateUser(id, params){
        this.props.updateUser(id, params, this.state.key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        );
    } 

    render()
    {
        const location = this.props.location;
        return (
            <tr> 
                <td>{location.id}</td>
                <td>{location.formatted_address}</td>
                <td>{location.city}</td>
                <td>{location.location_name}</td>
                <td>{location.swift_code}</td>
                <EditableCell ref="is_admin" type={'checkbox'} data={this.state.is_admin} /> 
                <EditableCell ref="sns_text" data={'Click to input text'} /> 
                <td>
                    <Button type="button" className="btn btn-success" bsSize="small" data-location_id={location.id} 
                        onClick={this.getParams}>Change admin <Glyphicon glyph="ok"/></Button>
                </td>
                <td>
                    <Link to={'/ltr/admin/location/edit/' + location.id}>
                        <Button type="button" className="btn btn-primary" bsSize="small">Message <Glyphicon glyph="edit"/></Button>
                    </Link>
                </td>
            </tr>
        );
    }
}

LocationListElement.propTypes = {
    updateUser: React.PropTypes.func.isRequired,
    pushSNS: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch) => {
    return {
        dispatch,
        ...bindActionCreators({
            updateUser: updateUser,
            pushSNS: pushSNS
        }, dispatch)
    };
};

export default connect(null, myDispatch)(LocationListElement);
