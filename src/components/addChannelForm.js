import React from 'react';
import {HelpBlock,PageHeader, Panel, Form, FormGroup, Col, Button, FormControl, InputGroup} from 'react-bootstrap';
import { Field, reduxForm} from 'redux-form';
import { connect } from 'react-redux';
import { routeActions } from 'react-router-redux';
import { addToChannel } from '../redux/actions/apiActions';
import { bindActionCreators } from "redux";


class AddChannel extends React.Component{
    constructor(props)
    {
        super(props);
        this.formSubmit = this.formSubmit.bind(this);
    }

    render(){
        const {handleSubmit} = this.props;
        return(
            <div>
                <Panel header={<h1>Add user to channel</h1>} bsStyle="info">
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
                            <label>Is invisible?</label>
                            <div>
                                <label><Field name="is_invisible" component="input" type="radio" value="true"/> True</label>
                                <label><Field name="is_invisible" component="input" type="radio" value="false"/> False</label>
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
                </Panel>
            </div>
        )
    }

    cancel(){
        this.props.router.goBack();
    }

    formSubmit(values){
        this.props.addToChannel(this.props.activeUser.id, values, localStorage.getItem('key')).then(
            (res) => {
                if(res.error){
                    alert(res.error)
                }
                else{
                    this.props.router.goBack()
                }
            }
        );
    }
}

AddChannel.propTypes = {
    addToChannel: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            addToChannel: addToChannel,
        }, dispatch)
    }
};

//decorate the form component
AddChannel = reduxForm({
    returnRejectedSubmitPromise : true,
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

export default connect(mapStateToProps, myDispatch)(AddChannel);
