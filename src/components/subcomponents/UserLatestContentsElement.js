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
        const content = this.props.content;

        return (
            <TimelineView withHeader className='border-hoverblue tl-blue'>
                <TimelineItem>
                    <TimelineHeader className='bg-hoverblue'>
                        <TimelineIcon className='bg-blue fg-white' glyph='icon-fontello-chat-1' />
                        <TimelineTitle>
                            Tue Jul 29 2014
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

export default connect()(UserLatestContentsElement);
