import React from 'react';
import {PageHeader, Form, FormGroup, Col, Button, FormControl, InputGroup} from 'react-bootstrap';
import { Field, reduxForm} from 'redux-form';
import { connect } from 'react-redux';

class UserEdit extends React.Component{
    form_type;
    constructor(props)
    {
        super(props);
        this.state = this.prop;
        //this.form_type = (props.initalValues.id > 0) ? 'edit' : 'add';
    }

    render(){

        return(
            <div>
                <PageHeader>User Edit</PageHeader>
                <Form horizontal>
                    <Field name="firstname" component={UserEdit.renderFirstName}/>
                    <Field name="phone" component={UserEdit.renderPhone}/>
                    <FormGroup>
                        <Col smOffset={2} sm={4}>
                            <Button type="submit">Save</Button>
                        </Col>
                    </FormGroup>
                </Form>
            </div>
        )
    }

    static renderFirstName(props){
        return (
            <FormGroup>
                <Col sm={2}> First Name</Col>
                <Col sm={4}> 
                    <FormControl {...props.input} id='firstname' type='text' placeholder='First Name'/>
                </Col>
            </FormGroup>
        )
    }

    static renderPhone(props){
        return (
            <FormGroup>
                <Col sm={2}>Phone Number</Col>
                <Col sm={4}> 
                    <FormControl {...props.input} id='phone' type='text' placeholder='Phone Number'/>
                </Col>
            </FormGroup>
        )
    }
}


//decorate the form component
UserEdit = reduxForm({
    form: 'user-edit',
})(UserEdit);

function mapStateToProps(state, own_props){
    let form_data = {
        firstname: "",
        phone: "",
    };

    for(const index in state.userReducer.users){
        if(state.userReducer.users[index].id === Number(own_props.params.id)){
            form_data.firstname = state.userReducer.users[index].first_name;
            form_data.phone = state.userReducer.users[index].phone_number;
            break;
        }
    }

    return{
        initialValues: form_data,
    }
}

export default connect(mapStateToProps)(UserEdit);
