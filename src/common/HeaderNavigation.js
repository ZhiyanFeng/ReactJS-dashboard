import React from 'react';
import ReactDOM from 'react-dom';
import classNames from 'classnames';
import { connect } from 'react-redux';

import { Link, withRouter } from 'react-router';

import l20n, { Entity } from '@sketchpixy/rubix/lib/L20n';
import {logout} from '../redux/actions/authActions';

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

@withRouter
class HeaderNavigation extends React.Component {
    logout(e){
        e.preventDefault();
        this.props.logout();
    }
    render() {
        return (
            <Nav pullRight>
                <Nav>
                    <NavItem className='logout' onClick={this.logout.bind(this)}>
                        <Icon bundle='fontello' glyph='off-1' />
                    </NavItem>
                </Nav>
            </Nav>
        );
    }
}

HeaderNavigation.propTypes = {
    logout: React.PropTypes.func.isRequired
}

export default connect(null, {logout})(HeaderNavigation);
