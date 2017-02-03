import React from 'react';
import classNames from 'classnames';
import { Link, withRouter } from 'react-router';
import TextFieldGroup from './TextFieldGroup';
import { connect } from 'react-redux';
import { login } from '../../redux/actions/authActions';

import {
  Row,
  Col,
  Icon,
  Grid,
  Form,
  Badge,
  Panel,
  Button,
  PanelBody,
  FormGroup,
  LoremIpsum,
  InputGroup,
  FormControl,
  ButtonGroup,
  ButtonToolbar,
  PanelContainer,
} from '../common';

import validateInput from './loginValidation';

@withRouter
class LoginForm extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            email: '',
            password: '',
            errors: {},
            isLoading: false
        };

        //this.onSubmit = this.onSubmit.bind(this);
    }

    isValid() {
        const { errors, isValid } = validateInput(this.state);
        if (!isValid) {
            this.setState({ errors });
        }
        return isValid;
    }

    onSubmit(e){
        e.preventDefault();
        if(this.isValid()){
            this.setState({errors: {}, isLoading: true});
            this.props.login(this.state).then(
                (res) => this.props.router.push('ltr/admin'),
                (err) => this.setState({ errors: err.data.errors, isLoading: false })
            );
        }
    }

    onChange(e){
        this.setState({[e.target.name]: e.target.value});
    }
    //back(e) {
    //    e.preventDefault();
    //    e.stopPropagation();
    //    this.props.router.goBack();
    //}

    componentDidMount() {
        $('html').addClass('authentication');
    }

    componentWillUnmount() {
        $('html').removeClass('authentication');
    }

    getPath(path) {
        var dir = this.props.location.pathname.search('rtl') !== -1 ? 'rtl' : 'ltr';
        path = `/${dir}/${path}`;
        return path;
    }

    render() {
        const {email, password, errors, isLoading} = this.state;
        return (
            <div id='auth-container' className='login' style={{"margin" : "200px auto 0 auto"}}>
                <div id='auth-row'>
                    <div id='auth-cell'>
                        <Grid>
                            <Row>
                                <Col sm={4} smOffset={4} xs={10} xsOffset={1} collapseLeft collapseRight>
                                    <PanelContainer controls={false}>
                                        <Panel>
                                            <PanelBody style={{padding: 0}}>
                                                <div className='text-center bg-darkblue fg-white'>
                                                    <h3 style={{margin: 0, padding: 25}}>Sign in to Shyft</h3>
                                                </div>
                                                <div className='bg-hoverblue fg-black50 text-center' style={{padding: 12.5}}>
                                                    <div>You need to sign in for those awesome features</div>
                                                </div>
                                                <div>
                                                    <div style={{padding: 0, paddingTop: 0, paddingBottom: 0, margin: 'auto', marginBottom: 0, marginTop: 25}}>
                                                        { errors.form && <div className="alert alert-danger">{errors.form}</div> }
                                                        <Form onSubmit={::this.onSubmit}>
                                                            <TextFieldGroup
                                                                field="email"
                                                                label="Email"
                                                                name="email"
                                                                value={email}
                                                                placeholder="yourname@myshyft.com"
                                                                error={errors.email}
                                                                onChange={::this.onChange}
                                                            />

                                                        <TextFieldGroup
                                                            field="password"
                                                            label="Password"
                                                            name="email"
                                                            value={password}
                                                            placeholder="password"
                                                            error={errors.password}
                                                            onChange={::this.onChange}
                                                            type="password"
                                                        />
                                                        <FormGroup>
                                                            <Grid>
                                                                <Row>
                                                                    <Col xs={6} collapseLeft collapseRight style={{paddingTop: 10}}>
                                                                        <Link to={::this.getPath('signup')}>Create a Shyft account</Link>
                                                                    </Col>
                                                                    <Col xs={6} collapseLeft collapseRight className='text-right'>
                                                                        <Button outlined lg type='submit' bsStyle='blue' disabled={isLoading}>Login</Button>
                                                                    </Col>
                                                                </Row>
                                                            </Grid>
                                                        </FormGroup>
                                                    </Form>
                                                </div>
                                            </div>
                                        </PanelBody>
                                    </Panel>
                                </PanelContainer>
                            </Col>
                        </Row>
                    </Grid>
                </div>
            </div>
        </div>
        );
    }
}
LoginForm.propTypes = {
    login: React.PropTypes.func.isRequired
}

LoginForm.contextTypes = {
    router: React.PropTypes.object.isRequired
}

export default connect(null, { login })(LoginForm);
