import React from 'react';
import { Link } from 'react-router';
import { Button, Glyphicon } from 'react-bootstrap';
import { connect  } from 'react-redux';
import { bindActionCreators } from "redux";
import EditableCell from './EditableCell.js';
import { updateUser } from "../redux/actions/apiActions";
import $ from 'jquery';

class UserListElement extends React.Component{
    constructor(props){
        super(props);
        this.state = {
            for_location : false
        }
        this.modalDeleteShow = this.modalDeleteShow.bind(this);
        this.updateUser = this.updateUser.bind(this);
        this.getParams = this.getParams.bind(this);
    }

    componentWillMount() {
        this.setState({
            ref: this.props.field,
            data: this.props.data,
            originalData: this.props.data,
            for_location: this.props.for_location,
            location_id: this.props.location_id
        });
    }

    modalDeleteShow(event){
        const userId = Number(event.target.dataset.id);
        const phoneNumber = event.target.dataset.phone_number;
        const for_location = event.target.dataset.for_location;
        this.props.dispatch({
            type: 'user.modalDelete',
            id: userId,
            phone: phoneNumber,
            for_location: this.state.for_location,
            location_id: this.state.location_id
        })
    }

    getParams(event){
        let params = {};
        let id = event.target.dataset.id;
        if(event.target.dataset.first_name !== this.refs.first_name.getValue()){
            params['first_name']= this.refs.first_name.getValue(); 
            this.refs.first_name.setDefault();
        }
        if(event.target.dataset.last_name !== this.refs.last_name.getValue()){
            params['last_name'] = this.refs.last_name.getValue(); 
            this.refs.last_name.setDefault();
        }
        if(event.target.dataset.phone_number !== this.refs.phone_number.getValue()){
            params['phone_number'] = this.refs.phone_number.getValue(); 
            this.refs.phone_number.setDefault();
        }
        if(!this.state.for_location){
            if(event.target.dataset.email !== this.refs.email.getValue()){
                let value = this.refs.email.getValue();
                const email = value =>
                    value && !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(value) ?
                        'Invalid email address' : undefined
                if(value && !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(value)){
                    alert("no valid email")
                }else if(value && /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(value)){
                    params['email'] = this.refs.email.getValue(); 
                    this.refs.email.setDefault();
                }
            }
        }
        if(this.state.for_location){
            if(event.target.dataset.is_admin !== this.refs.is_admin.getValue()){
                params['is_admin'] = this.refs.is_admin.getValue(); 
                params['location_id'] = this.state.location_id; 
                this.refs.is_admin.setDefault();
            }
        }

        if (!$.isEmptyObject(params)){
            this.updateUser(id, params);
        }
    }

    updateUser(id, params){
        let key = localStorage.getItem("key");
        this.props.updateUser(id, params, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        );
    } 

    render()
    {
        const user = this.props.user;
        //if(this.props.user != "no user"){
        return (
            <tr>
                <td>{user.id}</td>
                <EditableCell ref="first_name" data={user.first_name} /> 
                <EditableCell ref="last_name" data={user.last_name} /> 
                <EditableCell ref="phone_number" data={user.phone_number} /> 
                {this.state.for_location ? null: <EditableCell ref="email" data={user.email} />} 
                <td>{user.is_valid ? 'True' : 'False'}</td>
                {this.state.for_location ?
                        [
                            <td>{user.is_approved ? 'True' : 'False'}</td>,
                            <EditableCell ref="is_admin" data={user.is_admin ? 'True' : 'False'} /> 
                        ]
                        : <td>{user.created_at}</td>
                }
                <td>
                    <Button type="button" className="btn btn-success" bsSize="small" data-id={user.id} data-first_name={user.first_name} data-last_name={user.last_name}
                        data-phone_number={user.phone_number} data-email={user.email} data-for_location={true} onClick={this.getParams}>Edit <Glyphicon glyph="ok"/></Button>
                </td>
                <td>
                    <Link to={'/ltr/admin/user/edit/' + user.id}>
                        <Button type="button" className="btn btn-primary" bsSize="small">Details <Glyphicon glyph="edit"/></Button>
                    </Link>
                </td>
                {this.state.for_location
                        ? <td>
                            <Button type="button" className="btn btn-danger" bsSize="small" data-id={user.id} 
                                data-phone_number={user.phone_number} onClick={this.modalDeleteShow}>Delete from location<Glyphicon glyph="remove-circle"/></Button>
                        </td>
                        : <td>
                            <Button type="button" className="btn btn-danger" bsSize="small" data-id={user.id} 
                                data-phone_number={user.phone_number} onClick={this.modalDeleteShow}>Delete <Glyphicon glyph="remove-circle"/></Button>
                        </td>
                }
            </tr>
        );

    }
}

UserListElement.propTypes = {
    updateUser: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch) => {
    return {
        dispatch,
        ...bindActionCreators({
            updateUser: updateUser,
        }, dispatch)
    };
};
export default connect(null, myDispatch)(UserListElement);
