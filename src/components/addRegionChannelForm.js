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

    AddRegionChannel(query, admin){
            const config = {
                headers: {
                    'X-Method': 'pass_verification',
                    'Session-Token': '1333',
                    'Accept': 'application/vnd.Expresso.v1',
                    'Authorization': `Token token=${admin}, nonce="def"`,
                    'Content-Type': 'application/json'
                }
            }
        axios.post(`http://internal.coffeemobile.com/api/channels/create_region_channel`, {'channel_frequency': query.channel_frequency, 'channel_name':query.channel_name, 'channel_profile': query.channel_profile}, config).then(res => {
            });
        }

    render(){
        const {handleSubmit} = this.props;
        return(
            <div>
                <PageHeader>Create Region Channel</PageHeader>
                <Form horizontal onSubmit={this.props.handleSubmit(this.formSubmit)}>
                    <div>
                        <label>Channel Frequency</label>
                        <div>
                            <Field name="channel_frequency" component="input" type="text" placeholder="Channel Frequency"/>
                        </div>
                    </div>
                    <div>
                        <label>Channel Name</label>
                        <div>
                            <Field name="channel_name" component="input" type="text" placeholder="Channel Name"/>
                        </div>
                    </div>
                    <div>
                        <label>Channel Profile</label>
                        <div>
                            <Field name="channel_profile" component="input" type="text" placeholder="Channel Profile"/>
                        </div>
                    </div>
                    <div></div>
                    <FormGroup>
                        <Col smOffset={0.5} sm={4}>
                            <Button type="submit" className="btn btn-success" disabled={this.props.invalid || this.props.submitting}>Create Region Channel</Button>
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
        this.AddRegionChannel(values, localStorage.getItem('key'));
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
