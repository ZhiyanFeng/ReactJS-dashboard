import React from 'react';
import ReactDOM from 'react-dom';
import classNames from 'classnames';
import { connect } from 'react-redux';

import { Link, withRouter } from 'react-router';

import l20n, { Entity } from '@sketchpixy/rubix/lib/L20n';
import HeaderNavigation from './HeaderNavigation';

import {
  Label,
  SidebarBtn,
  Dispatcher,
  NavDropdown,
  NavDropdownHover,
  Navbar,
  Nav,
  NavItem,
  MenuItem,
  Badge,
  Button,
  Icon,
  Grid,
  Row,
  Radio,
    Col,
} from '../components/common';

class Brand extends React.Component {
    render() {
        return (
            <Navbar.Header {...this.props}>
                <Navbar.Brand tabIndex='-1'>
                    <a href='#'>
                        <img src='/imgs/common/logo.png' alt='rubix' width='111' height='28' />
                    </a>
                </Navbar.Brand>
            </Navbar.Header>
        );
    }
}


export default class Header extends React.Component {
    render() {
        return (
            <Grid id='navbar'>
                <Row>
                    <Col xs={12}>
                        <Navbar fixedTop fluid id='rubix-nav-header'>
                            <Row>
                                <Col xs={3} visible='xs'>
                                    <SidebarBtn />
                                </Col>
                                <Col xs={6} sm={4}>
                                    <Brand />
                                </Col>
                                <Col xs={3} sm={8} collapseRight className='text-right'>
                                    <HeaderNavigation {...this.props}/>
                                </Col>
                            </Row>
                        </Navbar>
                    </Col>
                </Row>
            </Grid>
        );
    }
}
