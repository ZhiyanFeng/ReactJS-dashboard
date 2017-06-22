import React from 'react';
import {Row, Panel, HelpBlock,PageHeader, Form, FormGroup, Col, Button, FormControl, InputGroup} from 'react-bootstrap';
import { Field, reduxForm} from 'redux-form';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';
import { searchUserDetail } from '../redux/actions/apiActions';
import { createLocation } from "../redux/actions/apiActions.js";
import { bindActionCreators } from "redux";


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
                            <label>Location name</label>
                            <div>
                                <Field name="location_name" style={{"width" : "100%"}} component="input" type="text" placeholder="Location name"/>
                            </div>
                        </FormGroup>
                        <FormGroup>
                            <label>Formatted address</label>
                            <div>
                                <Field name="formatted_address" style={{"width" : "100%"}} component="input" type="text" placeholder="Formatted address"/>
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
    validate: function(values){
        const errors ={};
        if(!values.location_name){
            errors.location_name = 'firstname is required';
        }
        if(!values.formatted_address){
            errors.location_name = 'address is required';
        }
        return errors;
    }
})(LocationCreate);

export default connect(null, myDispatch)(LocationCreate);
