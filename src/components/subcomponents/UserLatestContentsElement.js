import React from 'react';
import { Link } from 'react-router';
import { Button, Glyphicon } from 'react-bootstrap';
import { connect  } from 'react-redux';

import {
  Row,
  Col,
  Panel,
  PanelBody,
  LoremIpsum,
  TimelineBody,
  TimelineIcon,
  TimelineView,
  TimelineItem,
  TimelineTitle,
  TimelineHeader,
  PanelContainer,
} from '@sketchpixy/rubix';

class UserLatestContentsElement extends React.Component{
    constructor(props){
        super(props);
    }


    render()
    {
        if(this.props.type == "Post"){
            return (
                <TimelineView withHeader className='border-hoverblue tl-blue'>
                    <TimelineItem>
                        <TimelineHeader className='bg-hoverblue'>
                            <TimelineIcon className='bg-blue fg-white' glyph='icon-fontello-pencil-1' />
                            <TimelineTitle>
                                {this.props.created}
                            </TimelineTitle>
                        </TimelineHeader>
                        <TimelineBody>
                            <ul>
                                <li>
                                    {this.props.content}
                                </li>
                            </ul>
                        </TimelineBody>
                    </TimelineItem>
                </TimelineView>
            );
        } else if(this.props.type == "Comment") {
            return (
                <TimelineView withHeader className='border-hovergreen tl-green'>
                    <TimelineItem>
                        <TimelineHeader className='bg-hovergreen'>
                            <TimelineIcon className='bg-green fg-white' glyph='icon-fontello-comment' />
                            <TimelineTitle>
                                {this.props.created}
                            </TimelineTitle>
                        </TimelineHeader>
                        <TimelineBody>
                            <ul>
                                <li>
                                    Commented on this <a href="">post</a>
                                </li>
                            </ul>
                        </TimelineBody>
                    </TimelineItem>
                </TimelineView>
            );
        } else if(this.props.type == "Like") {
            return (
                <TimelineView withHeader className='border-hoverred tl-red'>
                    <TimelineItem>
                        <TimelineHeader className='bg-hoverred'>
                            <TimelineIcon className='bg-red fg-white' glyph='icon-fontello-heart-filled' />
                            <TimelineTitle>
                                {this.props.created}
                            </TimelineTitle>
                        </TimelineHeader>
                        <TimelineBody>
                            <ul>
                                <li>
                                    Liked this <a href="">post</a>
                                </li>
                            </ul>
                        </TimelineBody>
                    </TimelineItem>
                </TimelineView>
            );
        } else if(this.props.type == "Shift") {
            return (
                <TimelineView withHeader className='border-hoveryellow tl-yellow'>
                    <TimelineItem>
                        <TimelineHeader className='bg-hoveryellow'>
                            <TimelineIcon className='bg-yellow fg-white' glyph='icon-fontello-arrows-cw' />
                            <TimelineTitle>
                                {this.props.created}
                            </TimelineTitle>
                        </TimelineHeader>
                        <TimelineBody>
                            <ul>
                                <li>
                                    {this.props.content}
                                </li>
                            </ul>
                        </TimelineBody>
                    </TimelineItem>
                </TimelineView>
            );
        }
    }
}

export default connect()(UserLatestContentsElement);
