import React from 'react';
import { connect  } from 'react-redux';
import classNames from 'classnames';
import { withRouter } from 'react-router';
import { Link } from 'react-router';
import { Glyphicon } from 'react-bootstrap';
import { removeUserFromChannel } from "../redux/actions/apiActions.js";
import { bindActionCreators } from "redux";

import {
    Row,
    Col,
    Icon,
    Grid,
    Label,
    Badge,
    Panel,
    Button,
    PanelLeft,
    PanelBody,
    ListGroup,
    LoremIpsum,
    ButtonGroup,
    ButtonToolbar,
    ListGroupItem,
    PanelContainer,
} from '@sketchpixy/rubix';

class InboxItem extends React.Component {
    constructor(props){
        super(props);
        this.unsubscribe = this.unsubscribe.bind(this);
    }

    unsubscribe(){
        let key = localStorage.getItem("key");
        this.props.removeUserFromChannel(this.props.channelId, this.props.userId, key).then(
            this.props.dispatch({
                type: "user.unsubscribeChannel",
                channelId: this.props.channelId
            })
        );
    }

    render() {
        var classes = classNames({
            'inbox-item': true,
            'unread': this.props.unread
        });

        return (
                <div className='inbox-avatar'>
                    <img src={this.props.src} width='40' height='40' className={this.props.imgClass + ' hidden-xs'} />
                    <div className='inbox-avatar-name'>
                        <div className='fg-darkgrayishblue75'>{this.props.name}</div>
                        <div><small><Badge className={this.props.labelClass} style={{marginRight: 5, display: this.props.type ? 'inline':'none'}}>{this.props.type}</Badge><span>{this.props.member}</span></small></div>
                    </div>
                    <div className='inbox-date hidden-sm hidden-xs fg-darkgray40 text-right'>
                        <div style={{position: 'relative', top: 5}}>{this.props.date}</div>
                        <Button type="button" className="btn btn-danger" bsSize="small" onClick={this.unsubscribe}>remove <Glyphicon glyph="remove"/></Button>
                    </div>
                </div>
        );
    }
}


InboxItem.propTypes = {
    removeUserFromChannel: React.PropTypes.func.isRequired
};

const myDispatch = (dispatch) => {
    return {
        dispatch,
        ...bindActionCreators({
            removeUserFromChannel: removeUserFromChannel,
        }, dispatch)
    };
};

export default connect(null, myDispatch)(InboxItem);

