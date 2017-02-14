import React from 'react';
import { Link } from 'react-router';
import { connect  } from 'react-redux';
import { bindActionCreators } from "redux";
import _ from 'lodash';

import {
    Row,
    Col,
    Icon,
    Grid,
    Panel,
    Image,
    Button,
    Glyphicon,
    PanelBody,
    PanelHeader,
    PanelFooter,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

import { searchUserLatestContent } from '../redux/actions/apiActions';

class UserLatestContents extends React.Component{
    constructor(props){
        super(props);
        this.state = {
            latestContents: this.props.activeUserLatestContents,
        }
    }

    componentWillMount() {
        this.props.searchUserLatestContent(parseInt(this.props.activeUserId), localStorage.getItem('key'))
            .then( res=>{
                this.setState({
                    latestContents: this.props.activeUserLatestContents,
                });
            });

    }

    render()
    {
        //const contents = this.props.activeUserLatestContents;
        if(this.state.latestContents.length !== 0){
            return (
                <PanelContainer controls={false}>
                    <PanelBody style={{paddingBottom: 12.5}}>
                        <Grid>
                            <Row>
                                <Col xs={12} className='text-center'>
                                    <div className='text-left'>
                                        <div className='text-uppercase blog-sidebar-heading'>
                                            <small>Most Recent Contributions</small>
                                            {this.state.latestContents.map((id,title,content,type) => {
                                                return(
                                                    <UserLatestContentsElement id={id} title={title} content={content} type={type} />
                                                );
                                            })}
                                        </div>
                                    </div>
                                </Col>
                            </Row>
                        </Grid>
                    </PanelBody>
                </PanelContainer>
            );
        }else{
            return <p>isLoading...</p>
        }
    };
}

UserLatestContents.propTypes = {
    searchUserLatestContent: React.PropTypes.func.isRequired
}

const mapStateToProps = (state, ownProps) => {
    return {
        activeUserLatestContents: state.activeUserLatestContentsReducer.activeUserLatestContents,
    }
};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchUserLatestContent: searchUserLatestContent,
        }, dispatch)
    }
};

export default connect(mapStateToProps, myDispatch)(UserLatestContents);
