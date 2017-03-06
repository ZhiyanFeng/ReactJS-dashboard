import React from 'react';
import { connect  } from 'react-redux';
import classNames from 'classnames';
import { withRouter } from 'react-router';
import { Link } from 'react-router';

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

class InboxItem extends React.Component {
  handleClick(e) {
    e.preventDefault();
    e.stopPropagation();

    this.props.router.push('/ltr/admin/channel/add');
  }
  render() {
    var classes = classNames({
      'inbox-item': true,
      'unread': this.props.unread
    });

    var linkProps = {
      href: '/ltr/mailbox/mail',
      onClick: ::this.handleClick,
      className: classes,
    };

    return (
      <a {...linkProps}>
        <div className='inbox-avatar'>
          <img src={this.props.src} width='40' height='40' className={this.props.imgClass + ' hidden-xs'} />
          <div className='inbox-avatar-name'>
            <div className='fg-darkgrayishblue75'>{this.props.name}</div>
            <div><small><Badge className={this.props.labelClass} style={{marginRight: 5, display: this.props.type ? 'inline':'none'}}>{this.props.type}</Badge><span>{this.props.member}</span></small></div>
          </div>
          <div className='inbox-date hidden-sm hidden-xs fg-darkgray40 text-right'>
            <div style={{position: 'relative', top: 5}}>{this.props.date}</div>
            <div style={{position: 'relative', top: -5}}><small>#{this.props.itemId}</small></div>
          </div>
        </div>
      </a>
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
                          {this.props.channels.map((channel, index) =>{
                                  var channel=channel.channel;
                                  var src= channel.channel_profile_url!== null ? channel.channel_profile_url : "https://s3.amazonaws.com/shyftassets/avatar1.png";
                                  return(
                                      <InboxItem key={channel.id} unread src={src} type={channel.channel_type} name={channel.channel_name} member={channel.member_count}/>
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
  }
}

const mapStateToProps = (state) => {
    return {
        channels: state.channelReducer.channels,
    }
};

export default connect(mapStateToProps, null)(Inbox);


