import React from "react";
import { connect } from "react-redux";
import { Link, withRouter } from 'react-router';
import { Pagination } from "react-bootstrap";
import {push, routeActions}  from "react-router-redux";
import { bindActionCreators } from "redux";
import { searchUsers } from "../redux/actions/apiActions";
import { ModalDeleteUser } from "../redux/actions/actionTypes/modalDeleteUser";
import UserDelete from "../components/UserDelete";
import UserListElement from "../components/UserListElement";

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
} from "@sketchpixy/rubix";


class DatatableComponent extends React.Component {
    constructor(props) {
        super(props);
        this.updateSearch = this.updateSearch.bind(this);
        this._handleKeyPress = this._handleKeyPress.bind(this);
        this.changePage = this.changePage.bind(this);
    }

    updateSearch() {
        this.search(this.refs.searchInput.value, localStorage.getItem("key"));
    }

    search(query = "", key) {
        this.props.searchUsers(query, key).then(
        );
    }

    changePage(page){
        this.props.router.push(`/ltr/admin/tables/userList/?page=${page}`);
    }
    _handleKeyPress(e) {
        if (e.key === "Enter") {
            this.updateSearch();
        }
    }

    render() {
        const per_page =10;
        const pages = Math.ceil(this.props.users.length / per_page);
        const current_page = this.props.page;
        const start_offset = (current_page -1) * per_page;
        let start_count = 0;
        return (
            <div>
                <div>
                    <input ref="searchInput" type="text" id="serarchBox" onKeyPress={this._handleKeyPress} />
                    <button id="serachButton" onClick={(e) => { this.updateSearch(); }}>Search</button>
                </div>

                <Table ref={(c) => this.example = c} className='display' cellSpacing='0' width='100%'>
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Phone Number</th>
                            <th>Email</th>
                            <th>Is Valid</th>
                            <th>Created at</th>
                            <th>Edit</th>
                            <th>Details</th>
                            <th>Delete</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.props.users.map((user, index) => {
                            if(index >= start_offset && start_count < per_page){
                                start_count++;
                                return (
                                    <UserListElement key={user.id} user={user} />
                                );
                            }
                        })}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Phone Number</th>
                            <th>Email</th>
                            <th>Is Valid</th>
                            <th>Created at</th>
                            <th>Edit</th>
                            <th>Details</th>
                            <th>Delete</th>
                        </tr>
                    </tfoot>
                </Table>
                <div className="text-center">
                    <Pagination className="users-pagination text-center" bsSize="medium"
                        maxButtons={10} first last next prev boundaryLinks
                        items={pages} activePage={current_page} onSelect={this.changePage}/>
                </div>
                <UserDelete />
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
                                            <DatatableComponent {...this.props} />
                                            <br />
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
    searchUsers: React.PropTypes.func.isRequired,
};

const mapStateToProps = (state) => {
    return {
        users: state.userReducer.users,
        page: Number(state.routing.locationBeforeTransitions.query.page) || 1,
    }
};

const myDispatch = (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchUsers: searchUsers,
        }, dispatch)
    }
};

export default connect(mapStateToProps, myDispatch)(UserList);

