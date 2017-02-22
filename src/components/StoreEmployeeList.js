import React from 'react';
import axios from 'axios';
import { connect  } from 'react-redux';
import { bindActionCreators } from "redux";
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

//import {ModalDeleteUser} from "../redux/actions/actionTypes/modalDeleteUser";
import UserDelete from './UserDelete';
import UserListElement from './UserListElement';

class DatatableComponent extends React.Component {


    componentDidMount() {
        $(ReactDOM.findDOMNode(this.example))
            .addClass('nowrap')
        //.dataTable({
        //       columnDefs: [
        //           { targets: [-1, -3], className: 'dt-body-left' }
        //       ],
        //   });
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
                        {this.props.storeEmployees.map((storeEmployee, index) =>{
                            return(
                                <UserListElement key={storeEmployee.id} user={storeEmployee}/>
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
class StoreEmployeeList extends React.Component {
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

//const mapStateToProps = (state) => {
//    return {
//        admin: state.authReducer.admin
//    }
//
//};
//
//const myDispatch =  (dispatch, props) => {
//    return {
//        dispatch,
//        ...bindActionCreators({
//            searchUsers: searchUsers,
//        }, dispatch)
//    }
//};
export default StoreEmployeeList;

