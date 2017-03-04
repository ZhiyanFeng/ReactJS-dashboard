import React from 'react';
import { Link } from 'react-router';
import { Button, Glyphicon } from 'react-bootstrap';
import { connect  } from 'react-redux';

class UserListElement extends React.Component{
    constructor(props){
        super(props);
        this.modalDeleteShow = this.modalDeleteShow.bind(this);
    }

    modalDeleteShow(event){
        const userId = Number(event.target.dataset.id);
        const phoneNumber = event.target.dataset.phone_number;
        this.props.dispatch({
            type: 'user.modalDelete',
            id: userId,
            phone: phoneNumber,
        })

    }

    render()
    {
        if(this.props.user != "no user"){
            const user = this.props.user;
            return (
                <tr>
                    <td>{user.id}</td>
                    <td>{user.first_name}</td>
                    <td>{user.last_name}</td>
                    <td>{user.phone_number}</td>
                    <td>
                        <Link to={'/ltr/admin/user/edit/' + user.id}>
                            <Button type="button" className="btn btn-primary" bsSize="small">Edit <Glyphicon glyph="edit"/></Button>
                        </Link>
                    </td>
                    <td>
                        <Button type="button" className="btn btn-danger" bsSize="small" data-id={user.id} data-phone_number={user.phone_number} onClick={this.modalDeleteShow}>Delete <Glyphicon glyph="remove-circle"/></Button>
                    </td>
                </tr>
            );
        }else{
            return (
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            );
        }
    }
}

export default connect()(UserListElement);
