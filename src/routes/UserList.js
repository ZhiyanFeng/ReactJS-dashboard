import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import _ from 'lodash';

import {
    Row,
    Col,
    Grid,
    Panel,
    Table,
    PanelBody,
    PanelHeader,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

import {SelectUser} from "../redux/actions/actionTypes/selectUser";
import {ModalDeleteUser} from "../redux/actions/actionTypes/modalDeleteUser";
import UserDelete from '../components/UserDelete';
import UserListElement from '../components/UserListElement';


class DatatableComponent extends React.Component {


    componentDidMount() {
        $(ReactDOM.findDOMNode(this.example))
            .addClass('nowrap')
            .dataTable({
                responsive: true,
                columnDefs: [
                    { targets: [-1, -3], className: 'dt-body-left' }
                ],
            });
    }

    render() {
        return (
            <div>
                <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Phone Number</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.props.users.map((user, index) =>{
                            return(
                                <UserListElement key={user.id} user={user}/>
                            );
                        })}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Phone Number</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>
                    </tfoot>
                </Table>
                <UserDelete/>
            </div>
        );
    }
}

//@connect((state) => state.userReducer)
class UserList extends React.Component {
    render() {
        return (
            <Row>
                <Col xs={12}>
                    <PanelContainer>
                        <Panel>
                            <PanelBody>
                                <Grid>
                                    <Row>
                                        <Col xs={12}>
                                            <DatatableComponent {...this.props}/>
                                            <br/>
                                        </Col>
                                    </Row>
                                </Grid>
                            </PanelBody>
                        </Panel>
                    </PanelContainer>
                </Col>
            </Row>
        );
    }
}

const mapStateToProps = (state) => {
    return {
        users: state.userReducer.users,
    }

};

//const mapDispatchToProps = (dispatch) => {
//    return bindActionCreators({
//        selectUser: SelectUser, 
//        modalDelete: ModalDeleteUser,
//    }, dispatch);
//
//};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            selectUser: SelectUser, 
            modalDelete: ModalDeleteUser,
        }, dispatch)
    }
};
export default connect(mapStateToProps, myDispatch)(UserList);

