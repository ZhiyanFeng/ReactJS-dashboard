import React from 'react';
import { Link } from 'react-router';
import {Button, Glyphicon} from 'react-bootstrap';
import { connect  } from 'react-redux';
import axios from 'axios';

class channelListElement extends React.Component{
    constructor(props){
        super(props);
        this.recountChannel = this.recountChannel.bind(this);
        this.recountChannelApi = this.recountChannelApi.bind(this);
    }

    recountChannelApi(query, admin){
        const config = {
            headers: {
                'X-Method': 'pass_verification',
                'Session-Token': '1333',
                'Accept': 'application/vnd.Expresso.v1',
                'Authorization': `Token token=${admin}, nonce="def"`,
                'Content-Type': 'application/json'
            }
        }
        axios.get(`http://internal.coffeemobile.com/api/channels/${query}/recount`,  config).then(res => {
        });
    }

    recountChannel(){
        this.recountChannelApi(this.props.channel.id, localStorage.getItem('key'));
    }

    render()
    {
        const channel = this.props.channel;
        return (
            <tr> 
                <td>{channel.id}</td>
                <td>{channel.channel_name}</td>
                <td>{channel.member_count}</td>
                <td>{channel.description}</td>
                <td>{channel.channel_profile}</td>
                <td>
                    <Button type="button" className="btn btn-danger" bsSize="small" data-id={channel.id} onClick={this.recountChannel}> Recount </Button>
                </td>
            </tr>
        );
    }
}

export default connect()(channelListElement);
