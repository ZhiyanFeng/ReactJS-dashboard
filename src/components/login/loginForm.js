import React from 'react';
import TextFieldGroup from '../common/TextFieldGroup';
import {connect} from 'react-redux';
import axios from 'axios';


class LoginForm extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            identifier: '',
            password: '',
            errors: {},
            isLoading: false
        };

        this.onSubmit = this.onSubmit.bind(this);
        this.onChange = this.onChange.bind(this);
        this.login = this.login.bind(this);
    }

    onSubmit(e){
        e.preventDefault();
        this.login(this.state).then(
            (res)=> this.context.router.push('/')
        );
    }

    onChange(e){
        this.setState({
            [e.target.name]: e.target.value
        });
    }

    login(data){
            return axios.post('/api/auth', data);
    }

    render() {
        const {errors, identifier, password, isLoading} = this.state;
        return (
            <div className="login jumbotron center-block">
                <form onSubmit={this.onSubmit}>
                    <TextFieldGroup
                        field="identifier"
                        label="Username / Email"
                        value={identifier}
                        error={errors.identifier}
                        onChange={this.onChange}
                    />

                <TextFieldGroup
                    field="password"
                    label="Username / Email"
                    value={password}
                    error={errors.password}
                    onChange={this.onChange}
                    type="password"
                />

            <div className="form-group"><button className="btn btn-primary btn-lg" disabled={isLoading}>Login</button></div>
        </form>
    </div>
        );
    }
}
export default LoginForm;
