import React from 'react';
import axios from 'axios';

import {
  Row,
  Col,
  Nav,
  Grid,
  Form,
  Panel,
  Radio,
  Table,
  Button,
  Checkbox,
  PanelBody,
  FormGroup,
  InputGroup,
  PanelHeader,
  ButtonGroup,
  FormControl,
  PanelFooter,
  ControlLabel,
  PanelContainer,
} from '@sketchpixy/rubix';

export default class XEditable extends React.Component {
    constructor(props){
        super(props);
        this.state ={
            mode: 'popup',
        };
        this.updateUser = this.updateUser.bind(this);
        this.updateUserApiCall = this.updateUserApiCall.bind(this);
    }
    //static counter: 0;
    //static getCounter = function() {
    //    return 'counter-' + ++XEditable.counter;
    //};
    //static resetCounter = function() {
    //    XEditable.counter = 0;
    //};

    updateUser(value){
        this.editPhoneApiCall(this.props.operation, this.props.user, value, localStorage.getItem('key'));
    }

    updateUserApiCall(id, phone, key){
        const config = {
            headers: {
                'X-Method': 'pass_verification',
                'Session-Token': '1333',
                'Accept': 'application/vnd.Expresso.v1',
                'Authorization': `Token token=${key}, nonce="def"`,
                'Content-Type': 'application/json'
            }
        }
        if(opration === 'phone'){
            return axios.post(`http://internal.coffeemobile.com/api/users/${id}/update_user`, {'phone_number': query}, config).then(res => {
                //dispatch(setSearchUsers(res.data.eXpresso));
            });
        }
        if(opration === 'firstname'){
            return axios.post(`http://internal.coffeemobile.com/api/users/${id}/update_user`, {'first_name': query}, config).then(res => {
                //dispatch(setSearchUsers(res.data.eXpresso));
            });
        }
        if(opration === 'lastname'){
            return axios.post(`http://internal.coffeemobile.com/api/users/${id}/update_user`, {'last_name': query}, config).then(res => {
                //dispatch(setSearchUsers(res.data.eXpresso));
            });
        }
    }



    renderEditable() {
        // $('.xeditable').editable({
        // $(mode: this.state.mode
        //})// $(;
        var temp = this;
        $('#phone').editable({
            validate: function(value) {
                if($.trim(value) == ''){ 
                    return 'This field is required';
                }else{
                    temp.updateUser(value);
                };
            }
        });

        $('#firstname').editable({
            validate: function(value) {
                if($.trim(value) == ''){ 
                    return 'This field is required';
                }else{
                    temp.updateUser(value);
                };
            }
        });

        $('#lastname').editable({
            validate: function(value) {
                if($.trim(value) == ''){ 
                    return 'This field is required';
                }else{
                    temp.updateUser(value);
                };
            }
        });
    }

    componentDidMount() {
        this.renderEditable();
    }

    render() {
        var phone = this.props.phone !=null ? this.props.phone : 'Phone Number';
        var firstname = this.props.firstname !=null ? this.props.firstname : 'first name';
        var lastname = this.props.lastname !=null ? this.props.lastname : 'last name';
        if(this.props.operation === 'phone'){
            return(
                <h1 id='phone'>
                    <a href='#' ref='phoneNumber' className='xeditable' data-type='text' data-title='Enter phone_number'>{phone}</a>
                </h1>

            );
        }
        if(this.props.operation === 'firstname'){
            return(
                <h4 id='firstname' className='fg-white text-center'>
                    <a href='#' ref='firstname' className='xeditable' data-type='text' data-title='Enter firstname'>{firstname}</a>
                </h4>
            );
        }
        if(this.props.operation === 'lastname'){
            return(
                <h4 id='lastname' className='fg-white text-center'>
                    <a href='#' ref='lastname' className='xeditable' data-type='text' data-title='Enter lastname'>{lastname}</a>
                </h4>
            );
        }
    }
}
