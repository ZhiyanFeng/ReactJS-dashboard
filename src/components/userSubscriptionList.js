import React from 'react';
import { connect  } from 'react-redux';
import classNames from 'classnames';
import { withRouter } from 'react-router';
import { Link } from 'react-router';
import { Glyphicon } from 'react-bootstrap';
import { removeUserFromChannel } from "../redux/actions/apiActions.js";
import InboxItem from "./InboxItem.js";

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

class InboxNavItem extends React.Component {
    render() {
        return (

            <Grid>
                <Row>
                    <Col xs={8} collapseLeft collapseRight>
                        <Icon glyph={this.props.glyph} className='inbox-item-icon'/>
                        <span>{this.props.title}</span>
                    </Col>
                    <Col xs={4} className='text-right' collapseLeft collapseRight>
                        <div style={{marginTop: 5}}><Label className={this.props.labelClass}>{this.props.labelValue}</Label></div>
                    </Col>
                </Row>
            </Grid>
        );
    }
}

class InboxNavTag extends React.Component {
    render() {
        return (
            <Grid>
                <Row>
                    <Col xs={12} collapseLeft collapseRight>
                        <Badge className={this.props.badgeClass}>{' '}</Badge>
                        <span>{this.props.title}</span>
                    </Col>
                </Row>
            </Grid>
        );
    }
}


class Inbox extends React.Component {
    handleClick(e) {
        e.preventDefault();
        e.stopPropagation();
        //this.props.router.push('');
    }

    render() {
        if(this.props.channel){
            return (
                <div>
                    <PanelContainer className='inbox' collapseBottom>
                        <Panel>
                            <PanelBody style={{paddingTop: 0}}>
                                <Grid>
                                    <Row>
                                        <Col xs={8} style={{paddingTop: 12.5}}>
                                            <ButtonToolbar className='inbox-toolbar'>
                                                <ButtonGroup>
                                                    <Link to={'/ltr/admin/channel/add/'}>
                                                        <Button bsStyle='blue'>
                                                            <Icon glyph='icon-fontello-plus'/>
                                                        </Button>
                                                    </Link>
                                                </ButtonGroup>
                                            </ButtonToolbar>
                                        </Col>
                                    </Row>
                                </Grid>
                                <hr style={{margin: 0}}/>
                                <Panel horizontal>
                                    <PanelBody className='panel-sm-9 panel-xs-12' style={{ paddingTop: 0 }}>
                                        <Grid>
                                            <Row>
                                                <Col xs={12}>
                                                    {this.props.channel.map((channel, index) =>{
                                                        var channel=channel.channel;
                                                        var src= channel.channel_profile_url!== null ? channel.channel_profile_url : "https://s3.amazonaws.com/shyftassets/avatar1.png";
                                                        return(
                                                            <InboxItem key={channel.id} channelId={channel.id} unread src={src} type={channel.channel_type} name={channel.channel_name}
                                                                member={channel.member_count} userId={this.props.user.id}/>
                                                        );
                                                    })}
                                                </Col>
                                            </Row>
                                        </Grid>
                                    </PanelBody>
                                </Panel>
                            </PanelBody>
                        </Panel>
                    </PanelContainer>
                </div>
            );
        }else{
            return <p>Loading...</p>
        }
    }
}

const mapStateToProps = (state) => {
    return {
        channel: state.userReducer.channel,
    }
};

export default connect(mapStateToProps, null)(Inbox);
