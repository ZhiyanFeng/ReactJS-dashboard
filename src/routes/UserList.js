import React from 'react';
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

import {searchUsers} from '../redux/actions/apiActions';
import {ModalDeleteUser} from "../redux/actions/actionTypes/modalDeleteUser";
import UserDelete from '../components/UserDelete';
import UserListElement from '../components/UserListElement';

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
        this.props.searchUsers(query, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        )
    }

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
                        
                        {this.props.users ? this.props.users.map((user, index) =>{
                            return(
                                <UserListElement key={user.id} user={user}/>
                            );
                        }) : <p>No users</p>}
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
    searchUsers: React.PropTypes.func.isRequired
}

const mapStateToProps = (state) => {
    return {
        users: state.userReducer.users,
        admin: state.authReducer.admin
    }

};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchUsers: searchUsers,
        }, dispatch)
    }
};
export default connect(mapStateToProps, myDispatch)(UserList);

