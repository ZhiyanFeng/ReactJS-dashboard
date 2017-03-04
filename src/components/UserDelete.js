import React from 'react';
import {Modal, Button, Glyphicon} from 'react-bootstrap';
import { connect } from 'react-redux';


class UserDelete extends React.Component {
    constructor(props){
        super(props);
        this.modalDeleteHide = this.modalDeleteHide.bind(this);
        this.userDelete = this.userDelete.bind(this);
    }

    modalDeleteHide(event){
        this.props.dispatch({
            type: "user.modalDeleteHide",
        })
    };

    userDelete(event){
        //delete the user
        this.props.dispatch({
            type: 'user.delete',
            id: this.props.modal_delete.id,
        })

        this.props.dispatch({
            type: "user.modalDeleteHide",
        })

    }

    render(){
        return (
            <Modal show={this.props.modal_delete.show}>
                <Modal.Header>
                    <Modal.Title>
                        Are you sure you want to delete user with phone No.<strong> {this.props.modal_delete.phone}</strong>?
                    </Modal.Title>
                </Modal.Header>
                <Modal.Footer>
                    <Button onClick={this.modalDeleteHide}>No</Button>
                    <Button bsStyle="primary" onClick={this.userDelete}>Yes</Button>
                </Modal.Footer>
            </Modal>
        )
    }
}


function mapStateToProps(state){
    let modal_delete;
    if(state.userReducer.modal && state.userReducer.modal.list_delete){
        modal_delete = state.userReducer.modal.list_delete;
    }else{
        modal_delete={
            show: false,
            id: 0,
            phone: '',
        }
    }

    return{
        modal_delete: modal_delete,
    }
}


export default connect(mapStateToProps)(UserDelete);
