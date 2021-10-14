import React from 'react';
import { connect } from 'react-redux';

import './App.css';
import Routes from './routes';

import Navbar from './components/Navbar'



function App({logged}) {

  function IsLogged(props) {
    console.log(window.location.pathname)
    if(window.location.pathname !== '/' && window.location.pathname !== '/login')
      window.location.href = '/';
    console.log(props);
    if(props.isLoggedIn)
      return <Navbar />;
    else
      return '';
  }

  return (
    <div id='full'>
        <IsLogged isLoggedIn={logged}/>
        <Routes />
    </div>
  );
}

export default connect(state => ({ logged: state.logged }))(App);
