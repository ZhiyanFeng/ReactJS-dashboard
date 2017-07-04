import React from 'react';
import {Row, Panel, HelpBlock,PageHeader, Form, FormGroup, Col, Button, FormControl, InputGroup} from 'react-bootstrap';
import { Field, reduxForm} from 'redux-form';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';
import { searchUserDetail } from '../redux/actions/apiActions';
import { createLocation } from "../redux/actions/apiActions.js";
import { bindActionCreators } from "redux";


//define the constants
var divStyle = {
    color: 'red',
};

const required = value => value ? undefined : 'Required'
const maxLength = max => value =>
    value && value.length > max ? `Must be ${max} characters or less` : undefined
const maxLength15 = maxLength(15)
const number = value => value && isNaN(Number(value)) ? 'Must be a number' : undefined
const minValue = min => value =>
    value && value < min ? `Must be at least ${min}` : undefined
const minValue18 = minValue(18)
const email = value =>
    value && !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(value) ?
        'Invalid email address' : undefined
const tooOld = value =>
    value && value > 65 ? 'You might be too old for this' : undefined
const aol = value =>
    value && /.+@aol\.com/.test(value) ?
        'Really? You still use AOL for your email?' : undefined

const renderField = ({ input, label, type, meta: { touched, error, warning  }  }) => (
    <div>
        <label>{label}</label>
        <div>
            <input {...input} placeholder={label} style={{"width" : "100%"}} type={type}/>
            {touched && ((error && <div style={divStyle}>{error}</div>) || (warning && <div style={divStyle}>{warning}</div>))}
        </div>
    </div>
);

class LocationCreate extends React.Component{
    constructor(props)
    {
        super(props);
        this.formSubmit = this.formSubmit.bind(this);
    }

    render(){

        const {handleSubmit} = this.props;
        return(
            <div>
                <Panel header={<h1>Create a new location</h1>} bsStyle="info">
                    <Form onSubmit={this.props.handleSubmit(this.formSubmit)}>
                        <FormGroup>
                            <div>
                                <Field name="location_name" component={renderField} type="text" label="Location name" validate={[required]}/>
                            </div>
                        </FormGroup>
                        <FormGroup>
                            <div>
                                <Field name="formatted_address" component={renderField} type="text" label="Formatted address" validate={[required]} />
                            </div>
                        </FormGroup>
                        <FormGroup>
                            <Button type="submit" className="btn btn-success" disabled={this.props.invalid || this.props.submitting}>Save</Button>
                            <Button className="btn btn-danger" onClick={this.cancel.bind(this)}>Cancel</Button>
                        </FormGroup>
                    </Form>
                </Panel>
            </div>
        )
    }

    cancel(){
        this.props.router.goBack();
    }

    formSubmit(values){
        this.props.createLocation(values, localStorage.getItem('key')).then(
            (res) => {
                if(res.message){
                    alert(res.message)
                }
                else{
                    this.props.router.goBack()
                }
            }
        );
        //this.props.router.goBack();
    }
}

LocationCreate.propTypes = {
    createLocation: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            createLocation: createLocation,
        }, dispatch)
    }
};


//decorate the form component
LocationCreate = reduxForm({
    form: 'locationCreate',
    //validate: function(values){
    //    const errors ={};
    //    if(!values.location_name){
    //        errors.location_name = 'firstname is required';
    //    }
    //    if(!values.formatted_address){
    //        errors.location_name = 'address is required';
    //    }
    //    return errors;
    //}
})(LocationCreate);

export default connect(null, myDispatch)(LocationCreate);
