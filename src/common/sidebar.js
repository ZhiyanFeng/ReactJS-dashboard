import React from 'react';

import {
    Sidebar, SidebarNav, SidebarNavItem,
    SidebarControls, SidebarControlBtn,
    LoremIpsum, Grid, Row, Col, FormControl,
    Label, Progress, Icon,
    SidebarDivider
} from '@sketchpixy/rubix';

import { Link, withRouter } from 'react-router';

@withRouter
class ApplicationSidebar extends React.Component {
    handleChange(e) {
        this._nav.search(e.target.value);
    }

    getPath(path) {
            var dir = this.props.location.pathname.search('rtl') !== -1 ? 'rtl' : 'ltr';
            path = `/${dir}/${path}`;
            return path;
          
    }

    render() {
        return (
            <div>
                <Grid>
                    <Row>
                        <Col xs={12}>
                            <FormControl type='text' placeholder='Search...' onChange={::this.handleChange} className='sidebar-search' style={{border: 'none', background: 'none', margin: '10px 0 0 0', borderBottom: '1px solid #666', color: 'white'}} />
                            <div className='sidebar-nav-container'>
                                <SidebarNav style={{marginBottom: 0}} ref={(c) => this._nav = c}>

                                    { /** Pages Section */ }
                                    <div className='sidebar-header'>PAGES</div>
                                    <SidebarNavItem glyph='icon-fontello-gauge' name='Dashboard' href={::this.getPath('admin/dashboard')} />
                                    <SidebarNavItem href={::this.getPath('admin/tables/locationList')} glyph='glyphicon glyphicon-map-marker' name='Location search' />
                                    <SidebarNavItem href={::this.getPath('admin/locations/create')} glyph='glyphicon glyphicon-map-marker' name='Create location' />
                                    <SidebarNavItem href={::this.getPath('admin/tables/userList')} glyph='glyphicon glyphicon-user' name='User search' />
                                    <SidebarNavItem href={::this.getPath('admin/adminClaim')} glyph='glyphicon glyphicon-thumbs-up' name='Admin claim' />
                                    <SidebarNavItem href={::this.getPath('admin/channel/list')} glyph='icon-fontello-signal' name='Channel' />
                                    <SidebarDivider />
                                    <SidebarNavItem glyph='icon-ikons-login' name='Login' href={::this.getPath('login')} />

                                </SidebarNav>
                            </div>
                        </Col>
                    </Row>
                </Grid>
            </div>
        );
    }
}

class DummySidebar extends React.Component {
    render() {
        return (
            <Grid>
                <Row>
                    <Col xs={12}>
                        <div className='sidebar-header'>DUMMY SIDEBAR</div>
                        <LoremIpsum query='1p' />
                    </Col>
                </Row>
            </Grid>
        );
    }
}

@withRouter
export default class SidebarContainer extends React.Component {
    render() {
        return (
            <div id='sidebar'>
                <div id='avatar'>
                    <Grid>
                        <Row className='fg-white'>
                            <Col xs={4} collapseRight>
                                <img src='/imgs/app/avatars/admin.ico' width='40' height='40' />
                            </Col>
                            <Col xs={8} collapseLeft id='avatar-col'>
                                <div style={{top: 23, fontSize: 16, lineHeight: 1, position: 'relative'}}>{localStorage.getItem('admin')}</div>
                                <div>
                                    <Progress id='demo-progress' value={30} color='#ffffff'/>
                                    <a href='#'>
                                        <Icon id='demo-icon' bundle='fontello' glyph='lock-5' />
                                    </a>
                                </div>
                            </Col>
                        </Row>
                    </Grid>
                </div>
                <SidebarControls>
                    <SidebarControlBtn bundle='fontello' glyph='docs' sidebar={0} />
                    <SidebarControlBtn bundle='fontello' glyph='chat-1' sidebar={1} />
                    <SidebarControlBtn bundle='fontello' glyph='chart-pie-2' sidebar={2} />
                    <SidebarControlBtn bundle='fontello' glyph='th-list-2' sidebar={3} />
                    <SidebarControlBtn bundle='fontello' glyph='bell-5' sidebar={4} />
                </SidebarControls>
                <div id='sidebar-container'>
                    <Sidebar sidebar={0}>
                        <ApplicationSidebar />
                    </Sidebar>
                    <Sidebar sidebar={1}>
                        <DummySidebar />
                    </Sidebar>
                    <Sidebar sidebar={2}>
                        <DummySidebar />
                    </Sidebar>
                    <Sidebar sidebar={3}>
                        <DummySidebar />
                    </Sidebar>
                    <Sidebar sidebar={4}>
                        <DummySidebar />
                    </Sidebar>
                </div>
            </div>
        );
    }
}
