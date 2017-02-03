import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import _ from 'lodash';
import axios from 'axios';

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

import {search} from '../redux/actions/authActions';
import {ModalDeleteUser} from "../redux/actions/actionTypes/modalDeleteUser";
import UserDelete from '../components/UserDelete';
import UserListElement from '../components/UserListElement';
import Request from 'superagent';



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

    updateSearch(){
        this.search(this.refs.searchInput.value, localStorage.getItem('key'));
    }

    search(query="", key){
        this.props.search(query, key).then(
            (err) => this.setState({ errors: err.data.errors, isLoading: false  })
        )
    }


    //if(query!==""){
    //    var url =  `http://localhost:3000/api/users/search?user_name=${query}`;
    //    Request.get(url)
    //        .set({'x-method': 'pass_verification', 'accept': 'application/vnd.Expresso.v0', 'content-type': 'application/json'})
    //        .then((response)=>{
    //            this.props.getUsers(response.body.eXpresso);
    //        });
    //}


    render() {
        return (
            <div>
                <div>
                    <input ref="searchInput" type="text" id="serarchBox"/>
                    <button id="serachButton" onClick={(e)=>{this.updateSearch();}}>Search</button>
                </div>

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
UserList.propTypes = {
    search: React.PropTypes.func.isRequired
}

const mapStateToProps = (state) => {
    return {
        users: state.userReducer.users,
        admin: state.authReducer.admin
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
            search: search,
        }, dispatch)
    }
};
export default connect(mapStateToProps, myDispatch)(UserList);

