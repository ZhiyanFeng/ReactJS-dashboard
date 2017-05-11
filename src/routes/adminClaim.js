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

import { searchAdminClaim, allowClaim, sendEmail} from "../redux/actions/apiActions";

class DatatableComponent extends React.Component {
	constructor(props) {
		super(props);
		this.updateSearch = this.updateSearch.bind(this);
		this._handleKeyPress = this._handleKeyPress.bind(this);
        this.allowClaim = this.allowClaim.bind(this);
        this.sendEmail = this.sendEmail.bind(this);
	}
	updateSearch() {
		this.search(this.refs.searchInput.value, localStorage.getItem("key"));
	}

	search(query = "", key) {
		this.props.searchAdminClaim(query, key).then(
            //(err) => this.setState({ errors: err.data.errors, isLoading: false  })
        );
	}

	allowClaim(){
		var email= this.refs.email.textContent;
        var userId = this.refs.user_id.textContent;
        var locationId = this.refs.location_id.textContent;
		this.props.allowClaim(email, userId, locationId, localStorage.getItem("key")).then();
	}

    sendEmail(){
		var email= this.refs.email.textContent;
		this.props.sendEmail(email, localStorage.getItem("key")).then();
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
                    <tbody>
                        <tr>
                            <th>First Name: </th><td>{this.props.info.first_name}</td>
                        </tr>
                        <tr>
                            <th>Last Name: </th>
                            <td>{this.props.info.last_name}</td>
                        </tr>
                        <tr>
                            <th>User ID: </th>
                            <td ref="user_id">{this.props.info.user_id}</td>
                        </tr>
                        <tr>
                            <th>Claim Channel ID: </th>
                            <td>{this.props.info.channel_id}</td>
                        </tr>
                        <tr>
                            <th>Claim Channel Name: </th>
                            <td>{this.props.info.channel_name}</td>
                        </tr>
                        <tr>
                            <th>Location ID: </th>
                            <td ref="location_id">{this.props.info.location_id}</td>
                        </tr>
                        <tr>
                            <th>Location Address: </th>
                            <td>{this.props.info.location_address}</td>
                        </tr>
                        <tr>
                            <th>Claim Admin Email: </th>
                            <td ref="email"> {this.props.info.email}</td>
                        </tr>
                        <tr>
                            <th>Claim Date: </th>
                            <td>{this.props.info.claim_date}</td>
                        </tr>
                    </tbody>
                </Table>
                <hr />
                <div className="btn-group" role="group" aria-label="Basic example">
                    <button type="button" className="btn btn-secondary" onClick={(e) => { this.allowClaim(); }}>Allow</button>
                    <button type="button" className="btn btn-secondary" onClick={(e) => { this.sendEmail(); }}>Send email</button>
                </div>
            </div>
        );
    }
}

//@connect((state) => state.userReducer)
class AdminClaimList extends React.Component {
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

AdminClaimList.propTypes = {
    searchAdminClaim: React.PropTypes.func.isRequired,
    allowClaim: React.PropTypes.func.isRequired,
    sendEmail: React.PropTypes.func.isRequired
};

const mapStateToProps = (state) => {
    return {
        info: state.adminClaimReducer.info,
    };

};

const myDispatch = (dispatch) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchAdminClaim: searchAdminClaim,
            allowClaim: allowClaim,
            sendEmail: sendEmail
        }, dispatch)
    };
};
export default connect(mapStateToProps, myDispatch)(AdminClaimList);

