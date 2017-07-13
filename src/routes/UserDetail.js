import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import _ from 'lodash';
import { searchUserDetail,searchUserLatestContent, searchChannelForUser } from '../redux/actions/apiActions';

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

import UserLatestContents from '../components/UserLatestContents';
import UserSubscriptionList from '../components/userSubscriptionList';
import XEditable from '../components/XEditable';
import UserList from './UserList';

class UserDetailBanner extends React.Component {
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

    componentDidMount (){
        this.props.searchUserDetail(this.props.id, localStorage.getItem('key'))
            .then(res => {
                var url = this.props.activeUser.cover_image !==null ? this.props.activeUser.cover_image.full_url : "";
                this.setState({src: url});
            });
        this.props.searchChannelForUser(this.props.id, localStorage.getItem('key'))
            .then(res => {
                this.setState({chanael: this.props.channel});
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

    editPhone(event){
        const userId = Number(event.target.dataset.id);
        const phoneNumber = event.target.dataset.phone_number;
        this.props.dispatch({
            type: 'user.editPhone',
            id: userId,
            phone: phoneNumber,
        })

    }


    render() {
        return (
            <Row className='user'>
                <div style={{height: 350, marginTop: -25, backgroundImage: 'url(/imgs/app/shots/Blick_auf_Manhattan.JPG)', backgroundSize: 'cover', position: 'relative', marginBottom: 25, backgroundPosition: 'center'}}>
                    <div className='user-cover' style={{position: 'absolute', left: 0, right: 0, top: 0, bottom: 0, backgroundColor: 'rgba(0, 0, 0, 0.7)'}}>
                    </div>
                    <div className='user-desc'>
                        <div>
                            <XEditable operation='phone' phone={this.props.activeUser.phone_number} user={this.props.activeUser.id}/>
                            <h5 className='fg-white' style={{opacity: 0.8}}>Member Since - {this.props.activeUser.member_since}</h5>
                            <div style={{marginTop: 30}}>
                                <div className='desc-item'>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-pencil-6' />
                                    </Button>
                                    <label className='user-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.activeUser.posts_count} posts</span></label>
                                </div>
                                <div className='desc-item'>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-comment-1' />
                                    </Button>
                                    <label className='user-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.activeUser.comments_count} comments</span></label>
                                </div>
                                <div className='desc-item'>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-heart-1' />
                                    </Button>
                                    <label className='user-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.activeUser.likes_count} likes</span></label>
                                </div>
                            </div>
                            <div style={{marginTop: 9}}>
                                <div className='desc-item'>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-sort-number-up' />
                                    </Button>
                                    <label className='user-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.activeUser.shyft_score} score</span></label>
                                </div>
                                <div className='desc-item'>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-coverflow' />
                                    </Button>
                                    <label className='user-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.activeUser.number_of_shifts_covered} covers</span></label>
                                </div>
                                <div className='desc-item'>
                                    <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                        <Icon glyph='icon-fontello-upload-cloud' />
                                    </Button>
                                    <label className='user-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.activeUser.number_of_shifts_posted} posts</span></label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className='user-avatar'>
                        <Image src={this.state.src} height='100' width='100' style={{display: 'block', borderRadius: 100, border: '2px solid #fff', margin: 'auto', marginTop: 50}} />
                        <XEditable operation='firstname' firstname={this.props.activeUser.first_name}/>
                        <XEditable operation='lastname' lastname={this.props.activeUser.last_name}/>
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
                        <Col sm={12}>
                            <UserList />
                        </Col>
                        <Col sm={4} collapseRight>
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
                                                        <div><small className='fg-darkgray50'><em>{this.props.activeUser.last_fetch_counter}</em> - <span className='fg-lightgreen'>Fetch Counters</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>{this.props.activeUser.last_fetch_shift}</em> - <span className='fg-lightgreen'>Fetch Shifts</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>{this.props.activeUser.last_fetch_subscription}</em> - <span className='fg-lightgreen'>Fetch Subscriptions</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>{this.props.activeUser.last_fetch_chat}</em> - <span className='fg-lightgreen'>Fetch Chat</span></small></div>
                                                    </div>
                                                    <div style={{marginBottom: 12.5}}>
                                                        <div><small className='fg-darkgray50'><em>{this.props.activeUser.last_fetch_schedule}</em> - <span className='fg-lightgreen'>Fetch Schedule</span></small></div>
                                                    </div>
                                                    <div>
                                                        <div><small className='fg-darkgray50'><em>{this.props.activeUser.last_fetch_contact}</em> - <span className='fg-lightgreen'>Fetch Contact List</span></small></div>
                                                    </div>
                                                </div>
                                            </Col>
                                        </Row>
                                    </Grid>
                                </PanelBody>
                            </PanelContainer>
                        </Col>
                        <Col sm={4}>
                            <UserLatestContents activeUserId={this.props.id}/>
                        </Col>
                        <Col sm={4}>
                            <UserSubscriptionList channel={this.props.channel} user={this.props.activeUser}/> 
                        </Col>
                    </Row>
                </Col>
            </Row>
        );
    }
}

UserDetailBanner.propTypes = {
    searchUserDetail : React.PropTypes.func.isRequired,
    searchChannelForUser  : React.PropTypes.func.isRequired
}

const mapStateToProps = (state, ownProps) => {
    return {
        id: ownProps.params.id,
        activeUser: state.activeUserReducer.activeUser,
        channel: state.userReducer.channel,
    }
};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchUserDetail: searchUserDetail,
            searchChannelForUser: searchChannelForUser
        }, dispatch)
    }
};

export default connect(mapStateToProps, myDispatch)(UserDetailBanner);
