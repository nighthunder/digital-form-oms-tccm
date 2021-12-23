import React, {useEffect, useState } from 'react';
import { useHistory, useLocation} from "react-router-dom";
import { Button, TextField, CircularProgress } from '@material-ui/core';
import './styles.css';
import api from '../../services/api';
import { connect } from 'react-redux';

function Hospital({user}) {

    const history = useHistory();

    const location = useLocation();

    const [hospital, setHospital] = useState();
    const [search, setSearch] = useState('');
    const [error, setError] = useState('');
    const [hospitaisLoaded, setHospitaisLoaded] = useState(false);
    const [loadingSearch, setLoadingSearch] = useState(false);

    async function handleSearch(e) {
        e.preventDefault();
        setError('');
        setLoadingSearch(true);
        setHospitaisLoaded(false);
        console.log(user);
        const response = await api.post('/searchHospital', {
            descricao: search,
            userID: user[0].userid,
        }).catch( function (error) {
            setLoadingSearch(false);
            console.log(error)
            console.log(error.response.data)
        });
       
        if(response.data) {
            setLoadingSearch(false);
            setHospitaisLoaded(true);
            if(response.data.length > 0) {
                if(response.data[0].msgRetorno) {
                    setError(response.data[0].msgRetorno)
                } else {
                    setError('')
                }
            }
        }

        setHospital(response.data);
        console.log("hospital", hospital);
    }

    function handleChange(e) {
        const target = e.target;
        const value = target.value;
        console.log(value);
        setSearch(value);
    }

    return (
        <div>
        <main className="container">
            <div>
                <h2>Selecione o hospital</h2>
            </div>
            <div className="search-options">
                <form noValidate autoComplete="off" onSubmit={handleSearch}>
                    <TextField id="standard-basic" label="Nome do hospital" onChange={handleChange}/>
                    <Button variant="contained" color="primary" type="submit">
                        { !loadingSearch &&
                            'Buscar'
                        }
                        { loadingSearch &&
                            <CircularProgress color="white"/>
                        }
                    </Button>
                </form>
            </div>
            { (error) &&
                <span className="error">{ error }</span>
            }
            { !error && !hospital && !hospitaisLoaded &&
                <div className="modulos-list">
                    {user.map((hospital, index) => (
                        <div className="item" key={hospital.hospitalunitid }>
                            <div onClick={ () => {
                                history.push('/prontuario', { hospitalName: hospital.hospitalName, hospitalIndex: index })
                            }}>
                                <h4> {hospital.hospitalName} </h4>
                                <p> {hospital.userrole} </p>
                            </div>
                            { (hospital.userrole === "Administrador") && 
                                <Button variant="contained" color="primary" onClick={ () => {
                                    history.push('/cadastro', { hospitalId: hospital.hospitalunitid, hospitalIndex: index})
                                }}>Cadastrar usuários</Button>
                            }
                            { (hospital.userrole === "Administrador") && 
                                <Button variant="contained" color="primary" onClick={ () => {
                                    history.push('/survey', { hospitalId: hospital.hospitalunitid, hospitalIndex: index})
                                }}>Gerenciar pesquisas</Button>
                            }
                        </div>
                    ))}
                </div>
            }
            { !error && hospital && hospitaisLoaded &&
                <div className="modulos-list">
                    {hospital.map((hospital, index) => (
                        <div className="item" key={hospital.hospitalunitid }>
                            <div onClick={ () => {
                                history.push('/prontuario', { hospitalName: hospital.hospitalName, hospitalIndex: index })
                            }}>
                                <h4> {hospital.hospitalName} </h4>
                                <p> {hospital.userrole} </p>
                            </div>
                            { (hospital.userrole === "Administrador") && 
                                <Button variant="contained" color="primary" onClick={ () => {
                                    history.push('/cadastro', { hospitalId: hospital.hospitalunitid, hospitalIndex: index})
                                }}>Cadastrar usuários</Button>
                            }
                            { (hospital.userrole === "Administrador") && 
                                <Button variant="contained" color="primary" onClick={ () => {
                                    history.push('/survey', { hospitalId: hospital.hospitalunitid, hospitalIndex: index})
                                }}>Gerenciar pesquisas</Button>
                            }
                        </div>
                    ))}
                </div>
            }
        </main>
        </div>
    );
}

export default connect(state => ({ user: state.user }))(Hospital);