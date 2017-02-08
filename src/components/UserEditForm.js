import React from 'react';
import {HelpBlock,PageHeader, Form, FormGroup, Col, Button, FormControl, InputGroup} from 'react-bootstrap';
import { Field, reduxForm} from 'redux-form';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';
import { searchUserDetail } from '../redux/actions/apiActions';


class UserEdit extends React.Component{
    constructor(props)
    {
        super(props);
        let editUser = {};
        let id=0;
        this.formSubmit = this.formSubmit.bind(this);
    }

    componentWillMount(){
        
    }

    render(){
        return(
            <div>
                <PageHeader>User Edit</PageHeader>
                <Form horizontal onSubmit={this.props.handleSubmit(this.formSubmit)}>
                    <Field name="firstname" component={UserEdit.renderFirstName}/>
                    <Field name="phone" component={UserEdit.renderPhone}/>
                    <FormGroup>
                        <Col smOffset={2} sm={4}>
                            <Button type="submit" disabled={this.props.invalid || this.props.submitting}>Save</Button>
                        </Col>
                    </FormGroup>
                </Form>
            </div>
        )
    }

    static renderFirstName(props){
        return (
            <FormGroup validationState={!props.meta.touched ? null: (props.meta.error ? 'error': 'success')}>
                <Col sm={2}> First Name</Col>
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
                <Col sm={2}>Phone Number</Col>
                <Col sm={4}> 
                    <FormControl {...props.input} id='phone' type='text' placeholder='Phone Number'/>
                </Col>
            </FormGroup>
        )
    }

    formSubmit(values){
        //this.props.dispatch({
        //    type: 'users.' + this.form_type,
        //    id: values.id,
        //    firstname: values.username,
        //    job: values.job,
        //});

        //this.props.dispatch(goBack());
        this.props.router.goBack();
        //this.props.dispatch(this.routeActions.push('/tr/tables/datatables'));
    }
}


//decorate the form component
UserEdit = reduxForm({
    form: 'user-edit',
    validate: function(values){
        const errors ={};
        if(!values.firstname){
            console.log('validation', values);
            errors.firstname = 'firstname is required';
        }
        return errors;
    }
})(UserEdit);

function mapStateToProps(state, own_props){
    //    let form_data = {
    //        firstname: "",
    //        phone: "",
    //    };
    //
    //    for(const index in state.userReducer.users){
    //        if(state.userReducer.users[index].id === Number(own_props.params.id)){
    //            form_data.firstname = state.userReducer.users[index].first_name;
    //            form_data.phone = state.userReducer.users[index].phone_number;
    //            break;
    //        }
    //    }
    //
        return{
            id: own_props,
        }
}

export default connect(mapStateToProps, )(UserEdit);
