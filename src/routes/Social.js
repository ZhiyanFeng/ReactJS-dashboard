import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import _ from 'lodash';
import {searchUserDetail} from '../redux/actions/apiActions';

import {
    Row,
    Col,
    Icon,
    Grid,
    Panel,
    Image,
    Button,
    PanelBody,
    PanelHeader,
    PanelFooter,
    FormControl,
    PanelContainer,
} from '@sketchpixy/rubix';

class SocialBanner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            follow: 'follow me',
            followActive: false,
            likeCount: 999,
            likeActive: false,
            likeTextStyle: 'fg-white'
        };
    }
    componentWillMount (){
        this.props.searchUserDetail(this.props.id, localStorage.getItem('key'))
            .then(res => {
                this.setState({src: this.props.activeUser.cover_image.full_url});
            });
    }

    handleFollow() {
        this.setState({
            follow: 'followed',
            followActive: true
        });
    }

    handleLike() {
        this.setState({
            likeCount: 1000,
            likeActive: true,
            likeTextStyle: 'fg-orange75'
        });
    }

    render() {
        return (
            <Row className='social'>
                <div style={{height: 350, marginTop: -25, backgroundImage: 'url(/imgs/app/shots/Blick_auf_Manhattan.JPG)', backgroundSize: 'cover', position: 'relative', marginBottom: 25, backgroundPosition: 'center'}}>
                    <div className='social-cover' style={{position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, backgroundColor: 'rgba(0, 0, 0, 0.7)'}}>
                    </div>
                    <div className='social-desc'>
                        <div>
                            <h1 className='fg-white'>Empire State, NY, USA</h1>
                            <h5 className='fg-white' style={{opacity: 0.8}}>Member Since - Aug 20th, 2014</h5>
                            <div style={{marginTop: 30}}>
                                <div style={{display: 'inline-block'}}>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-pencil-6' />
                                    </Button>
                                    <label className='social-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.state.likeCount} posts</span></label>
                                </div>
                                <div style={{display: 'inline-block', marginLeft: 30}}>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-comment-1' />
                                    </Button>
                                    <label className='social-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.state.likeCount} comments</span></label>
                                </div>
                                <div style={{display: 'inline-block', marginLeft: 30}}>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-heart-1' />
                                    </Button>
                                    <label className='social-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.state.likeCount} likes</span></label>
                                </div>
                            </div>
                            <div style={{marginTop: 9}}>
                                <div style={{display: 'inline-block'}}>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-sort-number-up' />
                                    </Button>
                                    <label className='social-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.state.likeCount} score</span></label>
                                </div>
                                <div style={{display: 'inline-block', marginLeft: 30}}>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-coverflow' />
                                    </Button>
                                    <label className='social-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.state.likeCount} covers</span></label>
                                </div>
                                <div style={{display: 'inline-block', marginLeft: 30}}>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-upload-cloud' />
                                    </Button>
                                    <label className='social-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.state.likeCount} posts</span></label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className='social-avatar'>
                        <Image src={this.state.src} height='100' width='100' style={{display: 'block', borderRadius: 100, border: '2px solid #fff', margin: 'auto', marginTop: 50}} />
                        <h4 className='fg-white text-center'>{this.props.activeUser.first_name}</h4>
                        <h5 className='fg-white text-center' style={{opacity: 0.8}}>DevOps Engineer, NY</h5>
                        <hr className='border-black75' style={{borderWidth: 2}}/>
                        <div className='text-center'>
                            <Button outlined inverse retainBackground active={this.state.followActive} bsStyle='brightblue' onClick={::this.handleFollow}>
                                <span>{this.state.follow}</span>
                            </Button>
                        </div>
                    </div>
                </div>
                <Col xs={12}>
                    <Row>
                        <Col sm={6} collapseRight>
                            <PanelContainer controls={false}>
                                <PanelBody style={{paddingBottom: 12.5}}>
                                    <Grid>
                                        <Row>
                                            <Col xs={12} className='text-center'>
                                                <div className='text-left'>
                                                    <div className='text-uppercase blog-sidebar-heading'>
                                                        <small>Most Recent Activity</small>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>2 minutes ago</em> - <span className='fg-lightgreen'>Fetch Counters</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>5 hours ago</em> - <span className='fg-lightgreen'>Fetch Shifts</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>3 days ago</em> - <span className='fg-lightgreen'>Fetch Subscriptions</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>3 days ago</em> - <span className='fg-lightgreen'>Fetch Chat</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>3 days ago</em> - <span className='fg-lightgreen'>Fetch Schedule</span></small></div>
                                                    </div>
                                                    <div>
                                                        <div><small className='fg-darkgray50'><em>4 months ago</em> - <span className='fg-lightgreen'>Fetch Contact List</span></small></div>
                                                    </div>
                                                </div>
                                            </Col>
                                        </Row>
                                    </Grid>
                                </PanelBody>
                            </PanelContainer>
                        </Col>
                        <Col sm={6}>
                        </Col>
                    </Row>
                </Col>
            </Row>
        );
    }
}

SocialBanner.propTypes = {
    searchUserDetail : React.PropTypes.func.isRequired
}

const mapStateToProps = (state, ownProps) => {
    return {
        id: ownProps.params.id,
        activeUser: state.activeUserReducer.activeUser,
    }
};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchUserDetail: searchUserDetail,
        }, dispatch)
    }
};

export default connect(mapStateToProps, {searchUserDetail})(SocialBanner);
