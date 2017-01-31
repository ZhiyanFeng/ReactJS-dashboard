import React from 'react';
import LoginForm from './loginForm';

export default class LoginPage extends React.Component {
    render() {
        return (
            <div className="row">
                <div className="col-md-4 col-md-offset">
                    <LoginForm/>
                </div>
            </div>

        );
    }
}
