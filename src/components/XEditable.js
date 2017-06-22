import React from 'react';
import axios from 'axios';
import {updateUserApiCall} from '../redux/actions/apiActions.js';
import { bindActionCreators } from "redux";
import { connect } from 'react-redux';

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

class XEditable extends React.Component {
    constructor(props){
        super(props);
        this.state ={
            mode: 'popup',
            operation: '',
        };
        this.updateUser = this.updateUser.bind(this);
    }
    //static counter: 0;
    //static getCounter = function() {
    //    return 'counter-' + ++XEditable.counter;
    //};
    //static resetCounter = function() {
    //    XEditable.counter = 0;
    //};

    updateUser(value){
        this.props.updateUserApiCall(this.state.operation, this.props.user, value, localStorage.getItem('key'));
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
                    temp.setState({
                          operation: "phone"
                    });
                    temp.updateUser(value);
                };
            }
        });

        $('#firstname').editable({
            validate: function(value) {
                if($.trim(value) == ''){ 
                    return 'This field is required';
                }else{
                    temp.setState({
                          operation: "firstname"
                    });
                    temp.updateUser(value);
                };
            }
        });

        $('#lastname').editable({
            validate: function(value) {
                if($.trim(value) == ''){ 
                    return 'This field is required';
                }else{
                    temp.setState({
                          operation: "lastname"
                    });
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

XEditable.propTypes = {
    updateUserApiCall: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            updateUserApiCall: updateUserApiCall,
        }, dispatch)
    }
};

export default connect(null, myDispatch)(XEditable);
