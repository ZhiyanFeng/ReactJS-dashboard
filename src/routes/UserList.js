import React from "react";
import { connect } from "react-redux";
import { bindActionCreators } from "redux";
import ReactDOM from "react-dom";

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

import { searchUsers } from "../redux/actions/apiActions";
import { ModalDeleteUser } from "../redux/actions/actionTypes/modalDeleteUser";
import UserDelete from "../components/UserDelete";
import UserListElement from "../components/UserListElement";

class DatatableComponent extends React.Component {
    constructor(props) {
        super(props);
        this.updateSearch = this.updateSearch.bind(this);
        this._handleKeyPress = this._handleKeyPress.bind(this);
    }
    componentDidMount() {
        $(ReactDOM.findDOMNode(this.example))
            .addClass("nowrap");
        //.dataTable({
        //       columnDefs: [
        //           { targets: [-1, -3], className: 'dt-body-left' }
        //       ],
        //   });
    }

    updateSearch() {
        this.search(this.refs.searchInput.value, localStorage.getItem("key"));
    }

    search(query = "", key) {
        this.props.searchUsers(query, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        );
    }
    _handleKeyPress(e) {
        if (e.key === "Enter") {
            this.updateSearch();
        }
    }

    render() {
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
                            <th>Is Valid</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.props.users ? this.props.users.map((user, index) => {
                            return (
                                <UserListElement key={user.id} user={user} />
                            );
                        }) : <UserListElement user="no user" />}
                    </tbody>
                    <tfoot>
                        <tr>
                            <th>Id</th>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Phone Number</th>
                            <th>Is Valid</th>
                            <th>Edit</th>
                            <th>Delete</th>
                        </tr>
                    </tfoot>
                </Table>
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
    searchUsers: React.PropTypes.func.isRequired
};

const mapStateToProps = (state) => {
    return {
        users: state.userReducer.users,
    };

};

const myDispatch = (dispatch) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchUsers: searchUsers,
        }, dispatch)
    };
};
export default connect(mapStateToProps, myDispatch)(UserList);

