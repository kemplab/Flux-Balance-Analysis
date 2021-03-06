function [ results ] = cmpRxn(parsed,model)
% Compare reactions in a parsed `CellDesigner` model structure (imported by `parseCD`) and a COBRA model Matlab structure.
%
% USAGE:
%
%    [results] = cmpRxn(parsed, model)
%
% INPUTS:
%    parsed:     A parsed model structure generated by `parseCD` function.
%    model:      A COBRA model Matlab structure.
%
% OUTPUTS
%    results:    Consist of four fields
%
%                  * listOfFound - A list of reactions in the test
%                    model that are present in the
%                    reference COBRA model.
%                  * listOfNotFound - A list of reactions in the test
%                    model that are NOT present in the
%                    reference COBRA model.
%                  * found_rxns_and_mets - A list of matched reactions in both the
%                    test model and the COBRA model; The
%                    lists of substrates and products for
%                    each rections stored in the sub field of `rxns_mets`
%                  * list_of_rxns_not_present_in_ReferenceModel - A list of reactions in
%                    the reference model that are
%                    NOT included in the test model.
%
% EXAMPLE:
%
%    cmp_PD_recon2_result = cmpRxn(parsePD, recon2)
%
% .. there are three fields "meid, id and name"; we would like to compare the
% .. reaction IDs in Recon 2 to thoese three independent columns.
%
% .. Author: - Longfei Mao October 2014

% .. isempty(find(~cellfun('isempty',strfind(model.mets,secM_red))));

rxnList_p=parsed.r_info.ID(:,:);
[r_original,c_original]=size(parsed.r_info.ID);

rxnList_m(:,1)=model.rxns(:,1);


if isfield(model,'rxnNames')
    rxnList_m(:,2)=model.rxnNames(:,1);
end

rxnList_m(:,:)=lower(rxnList_m(:,:));%% Convert string to lowercase.
%rxnList_p=lower(rxnList_p);

results.main=rxnList_p;  % rxnList_p, the parsed CD model.



nF=1; % the number of found
nU=1; % the number of not found

a=0;
for r_p=1:length(rxnList_p(:,1)); % the number of the iteration is equal to the number of reactions in the parsed model.

    for numOfID=1:c_original;  % three different forms of ID, names;

        %% the rxn acts as the keywords in the searching
        rxn=strtrim(rxnList_p(r_p,numOfID)); % removing the leading and the trailing white space from the string.
        rxn{1}=lower(rxn{1}); %% Convert string to lowercase.

        % find(~cellfun('isempty',strfind(rxnList_m(:,1),name{2})))
        if ~ischar(rxn{1})
            disp(rxn{1})
            rxn{1}=char(rxn{1});
            % error('wrong');

        end

        if ~isempty(find(~cellfun('isempty',strfind(rxnList_m(:,1),rxn{1})))) % rxnList_m a COBRA model;
            results.main{r_p,c_original+2}='found';
            results.listOfFound(nF,1:c_original)=rxnList_p(r_p,1:c_original);  % rxnList_p parsed model; r_p is the reaction number in the matrix.
            results.listOfFound{nF,c_original+2}='Present in the Reference model';
            nF=nF+1;

            % if model.S.(:,r_p)(!=0)

            ind=find(~cellfun('isempty',strfind(rxnList_m(:,1),rxn{1}))); % ind contains the index for the reactions in the COBRA model.
            fprintf('ind_in_COBRA_model is %d and the r_p is %d \n',ind,r_p);
            if ind~=0

                % ind: the index in the COBRA model;
                % r_p: the index in th parsed model.

                %  model.mets(find(full(model.S(1,3))==1))
                %  find(full(model.S(:,3)))
                %                 cmSub.(results.listOfFound(nF,2)).(sub)(:,:)=model.mets(find(full(model.S(:,ind_in_COBRA_model))>0))
                %                 cmSub.(results.listOfFound(nF,2)).(pro)(:,:)=model.mets(find(full(model.S(:,ind_in_COBRA_model))<0))
                %a.(r_p)(:,1)=
                a=a+1;
                rea_P.ind(a,:).n=r_p;


                % rea_P.r(a,:)=parsed.r_info.reactant(r_p,:)
                % rea_P.br(a,:)=parsed.r_info.baseReactant(r_p,:);

                %                   rea_M.ind(a,:).n=ind;
                %                   rea_M.r(a,:)=parsed.r_info.reactant(ind,:)
                %                  rea_M.br(a,:)=parsed.r_info.baseReactant(ind,:)

                disp(a);

                % b=strcat('ddrrf_',num2str(ind));

                c_index(a,1:length(ind))=ind;  % ind contions all the possible reaction IDs in the COBRA model structure identified for the reactions in the parsed model structure (rxnList_p(r_p))

                %                 for ddd=1:length(ind)
                %
                %                     b=strcat('abc',num2str(ind(ddd)));
                %                     b1=[b,'_subs']
                %                     b2=[b,'_prod']
                %
                %                 end

                rxn_p_n=rxnList_p{r_p,1};%

                for rxnNUM=1:length(ind) % the reaction ID in the identified reaction list

                    b=strcat('abc',num2str(ind(rxnNUM)));
                    b1=[b,'_subs'];
                    b2=[b,'_prod'];

                    ind_M=transpose(full(model.S(:,ind(rxnNUM)))<0); % consumping metabolites;  % ind contains reaction IDs;

                    ind_M_p=transpose(full(model.S(:,ind(rxnNUM)))>0);

                    [i,j]=find(ind_M) % find the row number, and metabolite number of the substrate in the model
                    [i_p,j_p]=find(ind_M_p) % find the row number, and metabolite number of the product in the model

                    rea_M.rxns_mets.(rxn_p_n).(b)(1:length(i),1)=i; %i contains reaction number (for example, ind contains a list of 5 reactions (reaction IDs span from 1:500)).

                    rea_M.rxns_mets.(rxn_p_n).(b)(1:length(j),2)=j; %j contains metabolite rpw number;


                    rea_M.rxns_mets.(rxn_p_n).(b)(1:length(i_p),3)=i_p; %i contains reaction number (for example, ind contains a list of 5 reactions (reaction IDs span from 1:500)).

                    rea_M.rxns_mets.(rxn_p_n).(b)(1:length(j_p),4)=j_p; %j contains metabolite rpw number;

                    % rea_M.r.(b)(1:length(i),1:2)=num2str(rea_M.r.(b)(1:length(i),1:2))

                    for rxnN=1:length(i) % the list of number of reactions;
                        rea_M.rxns_mets.(rxn_p_n).(b1)(rxnN,1)=model.rxns(ind(rxnNUM));
                        rea_M.rxns_mets.(rxn_p_n).(b1)(rxnN,2:(length(j)+1))=model.mets(j);
                    end

                    for rxnN=1:length(i_p)
                        % rea_M.r.(b1)(rxnN,1)=model.rxns(ind(i));
                        rea_M.rxns_mets.(rxn_p_n).(b2)(rxnN,2:(length(j_p)+1))=model.mets(j_p);

                    end

                end
                %   r_p,1:c_original

                %
                %(find(full(model.S(:,ind))<0));

                %c_index(a,:);


                % ind_M=transpose(full(model.S(:,ind))<0);

                % model.mets(full(model.S(:,6296))<0); %% this is the
                % testing


                % rea_M.r.(b)=transpose(find(full(model.S(:,ind))<0));

                % model.mets(find(full(model.S(:,ind))<0));
                % rea_M.rxn.(b).rxn(a)=
                rea_M.c=c_index;

                for mm=1:length(ind_M);
                    disp(length(ind_M));
                    %model.mets(ind_M(1,mm));
                    % rea_M.rxn.(b).rxn(mm)=
                end

                % find(full(model.S(:,ind_in_COBRA_model))>0);
                % b.(r_p)(:,1)=model.mets(find(full(model.S(:,ind_in_COBRA_model))<0));
                % cmSub.(results.listOfFound(nF,2).(num2str(r_p))=parsed.r_info.reatant(r_p,:);
                %cmSub.(results.listOfFound(nF,2).(num2str(r_p))=parsed.r_info.product(r_p,:);

                %% cmp
                %                 for ss=1:length(sub);
                %                     strcmp(sub{ss},
                %
                %                 end
                %end

            end

            break;
        elseif numOfID==c_original
            results.listOfNotFound(nU,1:c_original)=rxnList_p(r_p,1:c_original);;
            results.listOfNotFound{nU,c_original+2}='Not Present in the Reference mode';
            nU=nU+1;
        end


    end

end
%results.rea_P=rea_P;
results.found_rxns_and_mets=rea_M; % reactions found and their matches in the COBRA model and list of substrates and products for the reaction.

%
% results.listOfFound(nF,1:c_original)
%

nL=1;rxnList_p_2=parsed.r_info.ID(:,:);
nn=1;

for col=1:c_original
    for row=1:r_original;

        masterList(nn,1)=rxnList_p_2(row,col);
        nn=nn+1;
    end
end

disp('start searching reactions present in the reference model but not in the CD model')
for r_m=1:length(rxnList_m(:,1));

    rxn=strtrim(rxnList_m(r_m,1)); % removing the leading and the trailing white space from the string.
    %         try
    %  if isempty(find(strcmpi(rxn,rxnList_p_2(:,col))))

    if isempty(find(strcmpi(rxn,masterList(:,1))))

        results.list_of_rxns_not_present_in_ReferenceModel(nL,1)=rxn;

        %isempty(find(~cellfun('isempty',strfind(rxnList_p(:,1),rxn{1}))));
        % results.main_{r_p,c_original+2}='found';
        % results.listOfFound(nF,1:3)=rxnList_p(r_p,1:3);
        %results.listOfFound{nF,c_original+2}='Present in the Reference mode';
        %nF=nF+1;
        %     else
        %
        %         results.listOfNotFound(nU,1:3)=rxnList_p(r_p,1:3);;
        %         results.listOfNotFound{nU,c_original+2}='Not Present in the Reference mode';
        %
        nL=nL+1;

        %         catch
        %             disp(rxnList_m{r_m,1})
        %             disp(rxnList_p(:,col))
        %         end

    end

end
