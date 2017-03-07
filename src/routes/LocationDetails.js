import React from 'react';
import { connect  } from 'react-redux';
import {bindActionCreators } from "redux";
import ReactDOM from 'react-dom';
import _ from 'lodash';
import { searchLocationDetail, searchStoreEmployees} from '../redux/actions/apiActions';
import { searchStorePhoto} from '../redux/actions/apiGoogleActions';
import  StoreEmployeeList from '../components/StoreEmployeeList';
import XEditableLocation from '../components/XEditableLocation';

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


class LocationBanner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            storePhoto: "",
            follow: 'follow me',
            followActive: false,
            likeCount: 999,
            likeActive: false,
            likeTextStyle: 'fg-white'
        };
        this.googleMapService = this.googleMapService.bind(this);
    }
    componentDidMount (){
        this.props.searchLocationDetail(this.props.id, localStorage.getItem('key'))
            .then(res => {
                this.googleMapService(this.props.locationDetail.google_map_id);
                this.setState({locationDetail: this.props.locationDetail,
                });
            });
        this.props.searchStoreEmployees(this.props.id, localStorage.getItem('key'))
            .then(res => {
                this.setState({storeEmployees: this.props.storeEmployees,
                });
            });
    }


    googleMapService(placeId){
        var service = new google.maps.places.PlacesService(document.createElement('div'));

        var temp = this;
        service.getDetails({
            placeId: placeId
        }, function(place, status) {
            if (status === google.maps.places.PlacesServiceStatus.OK) {
                let numberOfPhotos = place.photos.length;
                let photoObj = place.photos[Math.floor(Math.random() * numberOfPhotos)];
                let storePhoto = photoObj.getUrl({'maxWidth': photoObj.width, 'maxHeight': photoObj.height});
                temp.setState({storePhoto: storePhoto});
            }
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
        //if(this.state.storePhoto !== ""){
        return (
            <div>
            <Row className='locationDetail'>
                <div style={{height: 350, marginTop: -25, backgroundImage: this.state.storePhoto ? `url(${this.state.storePhoto})` : "", backgroundSize: 'cover', position: 'relative', marginBottom: 25, backgroundPosition: 'center'}}>
                    <div className='locationDetail-desc'>
                        <div>
                            <h1 className='fg-white'></h1>
                            <h5 className='fg-white' style={{opacity: 0.8}}>Member Since - </h5>
                            <div className='desc-item' >
                                <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                    <Icon glyph='icon-fontello-user-6' />
                                </Button>
                                <label className='locationDetail-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.locationDetail.member_count} members</span></label>
                            </div>
                            <div  className='desc-item'>
                                <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                    <Icon glyph='icon-fontello-clock-1' />
                                </Button>
                                <label className='locationDetail-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.locationDetail.shift_count} shifts</span></label>
                            </div>
                            <div  className='desc-item'>
                                <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                    <Icon glyph='icon-fontello-thumbs-up-1' />
                                </Button>
                                <label className='locationDetail-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}> {this.props.locationDetail.cover_count} covers</span></label>
                            </div>
                            <div className='desc-item'>
                                <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                    <Icon glyph='icon-fontello-menu-1' />
                                </Button>
                                <label className='locationDetail-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.locationDetail.channel_count} channels</span></label>
                            </div>
                            <div className='desc-item'>
                                <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                    <Icon glyph='icon-fontello-calendar' />
                                </Button>
                                <label className='locationDetail-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.locationDetail.schedule_count} schedules</span></label>
                            </div>
                            <div className='desc-item'>
                                <Button id='likeCount' retainBackground rounded bsStyle='orange75' active={this.state.likeActive}>
                                    <Icon glyph='icon-fontello-eye' />
                                </Button>
                                <label className='locationDetail-like-count' htmlFor='likeCount'><span className={this.state.likeTextStyle}>{this.props.locationDetail.admin_count} admin</span></label>
                            </div>
                        </div>
                    </div>
                    <div className='locationDetail-avatar'>
                        <Image src={this.state.src} height='100' width='100' style={{display: 'block', borderRadius: 100, border: '2px solid #fff', margin: 'auto', marginTop: 50}} />
                        <XEditableLocation location_id={this.props.locationDetail.id} operation='location_name' name={this.props.locationDetail.location_name}/>
                        <h5 className='fg-white text-center' style={{opacity: 0.8}}>DevOps Engineer, NY</h5>
                    </div>
                </div>
            </Row>
            <div>
                <StoreEmployeeList  storeEmployees={this.props.storeEmployees}/>
            </div>
        </div>
        );
    }
}

LocationBanner.propTypes = {
    searchLocationDetail : React.PropTypes.func.isRequired,
    searchStoreEmployees : React.PropTypes.func.isRequired,
}

const mapStateToProps = (state, ownProps) => {
    return {
        id: ownProps.params.id,
        locationDetail: state.locationDetailReducer.locationDetail,
        storeEmployees: state.userReducer.storeEmployees,
        storePhoto: state.storePhotoReducer.storePhoto,
    }
};

const myDispatch =  (dispatch, props) => {
    return {
        dispatch,
        ...bindActionCreators({
            searchLocationDetail: searchLocationDetail,
            searchStorePhoto: searchStorePhoto,
            searchStoreEmployees: searchStoreEmployees,
        }, dispatch)
    }
};

export default connect(mapStateToProps, myDispatch)(LocationBanner);
