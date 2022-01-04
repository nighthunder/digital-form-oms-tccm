// Lista de todas as pesquisas

import React, { useState, useEffect } from 'react';
import { useHistory, useLocation, Link } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import api from '../../services/api';
import { Button, TextField, CircularProgress} from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import './styles.css';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';

import { connect } from 'react-redux';

function ListSurvey({user, hospital}) {

    const location = useLocation();
    const history = useHistory();

    const [search, setSearch] = useState('');
    const [questionnaires, setQuestionnaires] = useState([]);
    const [error, setError] = useState('');
    const [questionnairesLoaded, setQuestionnairesLoaded] = useState(false);
    const [loadingSearch, setLoadingSearch] = useState(false);
    const [popupTitle, setPopupTitle] = useState('');
    const [popupBodyText, setPopupBodyText] = useState('');

    useEffect(() => {
        async function loadQuestionnaires() {
            const response = await api.get('/survey');
            setQuestionnaires(response.data);
        }
        loadQuestionnaires();

    }, [])

    function getPtBrDate(somedate) {
        //var today = new Date();
        var dd = String(somedate.getDate()).padStart(2, '0');
        var mm = String(somedate.getMonth() + 1).padStart(2, '0');
        var yyyy = somedate.getFullYear();
        return dd + '/' + mm + '/' + yyyy;
    }

    function handleBackButton(){
        history.goBack();
    }

    async function handleSearch(e) {
        e.preventDefault();
        setError('');
        setLoadingSearch(true);
        setQuestionnairesLoaded(false);
        const response = await api.post('/searchSurvey', {
            descricao: search,
        }).catch( function (error) {
            setLoadingSearch(false);
            console.log(error)
            console.log(error.response.data)
        });
       
        if(response.data) {
            setLoadingSearch(false);
            setQuestionnairesLoaded(true);
            if(response.data.length > 0) {
                if(response.data[0].msgRetorno) {
                    setError(response.data[0].msgRetorno)
                } else {
                    setError('')
                }
            }

        }

        setQuestionnaires(response.data)
        console.log(response.data);
    }
    
    function handleChange(e) {
        const target = e.target;
        const value = target.value;
        console.log(value);
        setSearch(value);
    }

    // popup
    const [open, setOpen] = React.useState(false);
    const handleClickOpen = () => {
        setOpen(false);
        setPopupTitle("Como deseja criar seu questionário ? ");
        setPopupBodyText("");
        setOpen(true);
    };
    const handleAddSurvey = () => {
        history.push('/add-survey');
    };
    const handleAddBasedSurvey = () => {
        history.push('/add-based-survey');
    };
    const handleClose = () => {
        setOpen(false);
    };

	return (
            <main className="container containerWider prontuarios">
                <div className="survey">
                    <div className="mainNav">
				        <h2 id="title">Crie e edite pesquisas</h2>
                        <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                        <Scrollchor to="#vodan_br"><ArrowUpwardIcon className="ArrowUp" /></Scrollchor>
                    </div>
                    <div className="survey-details">
                        Gerencie as pesquisas: : crie, versione, copie, edite e publique.
                    </div>
                    <div className="search-options">
                        <form noValidate autoComplete="off" onSubmit={handleSearch}>
                            <TextField id="standard-basic" label="Descrição da pesquisa " onChange={handleChange}/>
                            <Button variant="contained" color="primary" type="submit">
                                { !loadingSearch &&
                                    'Buscar'
                                }
                                { loadingSearch &&
                                    <CircularProgress color="white"/>
                                }
                            </Button>
                        </form>
                        <Button variant="outlined" color="primary" className="add-survey" onClick={handleClickOpen}>
                        <Add color="primary" />
                        Adicionar pesquisa
                        </Button>    
                    </div>
                    <Dialog key={Math.random()}
                            open={open}
                            onClose={handleClose}
                            aria-labelledby="alert-dialog-title"
                            aria-describedby="alert-dialog-description"
                            >
                            <DialogTitle id="alert-dialog-title">
                                {popupTitle}
                            </DialogTitle>
                            <DialogContent>
                                <DialogContentText id="alert-dialog-description">
                                {popupBodyText}
                                </DialogContentText>
                            </DialogContent>
                            <DialogActions>
                                <Button onClick={handleClose}>Fechar [x]</Button>
                                <Button onClick={handleAddSurvey}>Do zero</Button>
                                <Button onClick={handleAddBasedSurvey} autoFocus> Por derivação
                                </Button>
                            </DialogActions>
                    </Dialog>
                    { (error) &&
                        <span className="error">{ error }</span>
                    }
                    { !error &&
                    <div className="surveys-list">
                        <table>
                                <thead>
                                    <tr>
                                        <th>PESQUISA</th>
                                        <th>VER.</th> 
                                        <th>STATUS</th>
                                        <th>CRIADO EM</th> 
                                        <th>MODIFICADO EM</th> 
                                        <th>EDITAR</th> 
                                    </tr>
                                </thead>
                                <tbody>
                                {
                                    questionnaires.map(q => ( 
                                        <tr key={q.questionnaireID} data-key={q.questionnaireID} onClick={ () => {
                                        history.push('/show-survey/', 
                                        {
                                        questionnaireID: q.questionnaireID, 
                                        description : q.description,
                                        version : q.version,
                                        questionnaireStatus : q.questionnaireStatus,
                                        lastModification: getPtBrDate(new Date(q.lastModification)),
                                        creationDate: getPtBrDate(new Date(q.creationDate))
                                        })
                                        }}>
                                            <td>{q.description}</td>
                                            <td><span className="detail">{q.version}</span></td>
                                            <td>{q.questionnaireStatus}</td>
                                            <td>{getPtBrDate(new Date(q.creationDate))}</td> 
                                            <td>{getPtBrDate(new Date(q.lastModification))}</td> 
                                            <td><Edit /></td>
                                        </tr>
                            
                                     ))
                                 }
                                 </tbody>
                            
                        </table>
                    </div>
                    }  
			    </div>
            </main>
     );

}

export default connect(state => ({ user: state.user }))(ListSurvey);