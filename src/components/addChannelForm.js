import React from 'react';
import axios from 'axios';
import {HelpBlock,PageHeader, Form, FormGroup, Col, Button, FormControl, InputGroup} from 'react-bootstrap';
import { Field, reduxForm} from 'redux-form';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';
import { searchUserDetail } from '../redux/actions/apiActions';


class AddChannel extends React.Component{
    constructor(props)
    {
        super(props);
        this.formSubmit = this.formSubmit.bind(this);
    }

    addToChannel(query, admin){
            const config = {
                headers: {
                    'X-Method': 'pass_verification',
                    'Session-Token': '1333',
                    'Accept': 'application/vnd.Expresso.v1',
                    'Authorization': `Token token=${admin}, nonce="def"`,
                    'Content-Type': 'application/json'
                }
            }
        axios.post(`http://internal.coffeemobile.com/api/users/${this.props.activeUser.id}/create_subscription`, {'user_id': this.props.activeUser.id, 'channel_id':query.channel_id, 'is_coffee': query.is_coffee, 'is_invisible': query.is_active}, config).then(res => {
            });
        }

    render(){
        const {handleSubmit} = this.props;
        return(
            <div calssName="modal">
                <PageHeader>Add user to channel</PageHeader>
                <Form horizontal onSubmit={this.props.handleSubmit(this.formSubmit)}>
                    <div>
                        <label>First Name</label>
                        <div>
                            <Field name="firstName" component="input" type="text" placeholder={this.props.activeUser.first_name}/>
                        </div>
                    </div>
                    <div>
                        <label>Channel Id</label>
                        <div>
                            <Field name="channel_id" component="input" type="text" placeholder="Channel Id"/>
                        </div>
                    </div>
                    <div>
                        <label>Is coffee?</label>
                        <div>
                            <label><Field name="is_coffee" component="input" type="radio" value="true"/> True</label>
                            <label><Field name="is_coffee" component="input" type="radio" value="false"/> False</label>
                        </div>
                    </div>
                    <div>
                        <label>Is active?</label>
                        <div>
                            <label><Field name="is_active" component="input" type="radio" value="true"/> True</label>
                            <label><Field name="is_active" component="input" type="radio" value="false"/> False</label>
                        </div>
                    </div>
                    <div></div>
                    <FormGroup>
                        <Col smOffset={0.5} sm={4}>
                            <Button type="submit" className="btn btn-success" disabled={this.props.invalid || this.props.submitting}>Save</Button>
                            <Button className="btn btn-danger" onClick={this.cancel.bind(this)}>Cancel</Button>
                        </Col>
                    </FormGroup>
                </Form>
            </div>
        )
    }

    static renderFirstName(props){
        return (
            <FormGroup validationState={!props.meta.touched ? null: (props.meta.error ? 'error': 'success')}>
                <Col sm={4}> 
                    <FormControl {...props.input} id='firstname' type='text' placeholder='First Name'/>
                    <FormControl.Feedback/>
                    <HelpBlock>{props.meta.touched && props.meta.error ? props.meta.error : null}</HelpBlock>
                </Col>
            </FormGroup>
        )
    }

    static renderPhone(props){
        return (
            <FormGroup>
                <Col sm={4}> 
                    <FormControl {...props.input} id='phone' type='text' placeholder='Phone Number'/>
                </Col>
            </FormGroup>
        )
    }

    cancel(){
        this.props.router.goBack();
    }

    formSubmit(values){
        this.addToChannel(values);
        this.props.router.goBack();
    }
}


//decorate the form component
AddChannel = reduxForm({
    form: 'addChannel',
    validate: function(values){
        const errors ={};
        if(!values.firstname){
            errors.firstname = 'firstname is required';
        }
        return errors;
    }
})(AddChannel);

const mapStateToProps = (state, ownProps) => {
    return {
        id: ownProps.params.id,
        activeUser: state.activeUserReducer.activeUser,
        channel: state.userReducer.channel,
    }
};

export default connect(mapStateToProps, null)(AddChannel);
