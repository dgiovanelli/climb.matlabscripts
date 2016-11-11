% %LINK RELIABILITY
% GRAPH_EDGES_M = GRAPH_EDGES_M_FILT;
% fprintf('LINKS RELIABILITY CHECK:\n');
% LINKS_UNRELIABLITY = zeros(size(GRAPH_EDGES_M));
% for i_link_1=1:size(GRAPH_EDGES_M,2) %scan all LINKS and evaluate all possible 'triangles'.
%     
%     id_1 = LINKS(1,i_link_1);
%     id_2_temp = LINKS(2,LINKS(1,:)==id_1);
%     id_2 = id_2_temp(1);
%     i_links_2_temp = find(LINKS(1,:)==id_2);
%     for i_link_2=i_links_2_temp
%         id_3 = LINKS(2,i_link_2);
%         i_link_3 = find(LINKS(2,:)==id_3 & LINKS(1,:)==id_1);
%         
%         if(size(i_link_3) == 1 )
%             
%             for timeIndexNo = 1:size(GRAPH_EDGES_M,1)
%                 if (GRAPH_EDGES_M(timeIndexNo,i_link_1)~=Inf) && (GRAPH_EDGES_M(timeIndexNo,i_link_2)~=Inf) && (GRAPH_EDGES_M(timeIndexNo,i_link_3)~=Inf)
%                     if GRAPH_EDGES_M(timeIndexNo,i_link_1) + GRAPH_EDGES_M(timeIndexNo,i_link_2) <  0.9*GRAPH_EDGES_M(timeIndexNo,i_link_3)
%                         %LINKS(i_link_3) -> unreliable
%                         LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
%                     end
%                     if GRAPH_EDGES_M(timeIndexNo,i_link_2) + GRAPH_EDGES_M(timeIndexNo,i_link_3) <  0.9*GRAPH_EDGES_M(timeIndexNo,i_link_1)
%                         %LINKS(i_link_1) -> unreliable
%                         LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
%                     end
%                     if GRAPH_EDGES_M(timeIndexNo,i_link_3) + GRAPH_EDGES_M(timeIndexNo,i_link_1) <  0.9*GRAPH_EDGES_M(timeIndexNo,i_link_2)
%                         %LINKS(i_link_2) -> unreliable
%                         LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
%                     end
%                 end
%             end
%         else
%             if ~isempty(i_link_3)
%                 error('i_link_3 has more than one element, check!!!');
%             end
%         end
%     end
% end
% fprintf('Done!\n\n');
% 
% figure(200)
% plot(t, GRAPH_EDGES_M_FILT);
% xlabel('Time [s]');
% ylabel('distance [m]');
% legend('TAGs','distance');
% title('All LINKS');
% grid on;
% hold off;
% 
% % fprintf('Click on the analysis bounds!\n');
% % [x1,~] = ginput(1);
% % [x2,~] = ginput(1);
% % if x1 > x2 
% %     xstop = x1;
% %     xstart = x2;
% % else
% %     xstop = x2;
% %     xstart = x1;
% % end
% 
% % tmp = abs(t - xstart);
% % [ ~ , xstart_index] = min(tmp);
% % tmp = abs(t - xstop);
% % [ ~ , xstop_index] = min(tmp);
% 
% xstart_index = 1;
% xstop_index = size(GRAPH_EDGES_M_FILT,1);
% %% CALCULATING NODES LAYOUT
% % NOTE: for now, changing the spring constant has no evident effect on
% % layout. Moreover neato fail to layouts a matematical straigt line such as:
% % graph G{
% % 1 -- 2[len="1",weight="1";
% % 2 -- 3[len="1",weight="1";
% % 1 -- 3[len="2",weight="1";
% % }
% fprintf('CALCULATING LAYOUT:\n');
% NODE_POSITION_ID_XY = zeros(length(AVAILABLE_IDs),3,xstop_index-xstart_index);
% timeIndexNo_for_nodePositionXY = 1;
% nextPercentPlotIndex = xstart_index;
% str = [];
% for timeIndexNo = xstart_index : xstop_index
%     CENTERING_OFFSET_XY = [0,0];
%     switch LAYOUT_ALGORITHM
%         case 0 % use neato to place nodes
%             if timeIndexNo == xstart_index
%                 createDOTdescriptionFile( GRAPH_EDGES_M_FILT(timeIndexNo,:), LINKS, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
%             else
%                 createDOTdescriptionFile( GRAPH_EDGES_M_FILT(timeIndexNo,:), LINKS, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',NODE_POSITION_ID_XY(:,:,timeIndexNo_for_nodePositionXY-1));
%             end
%             [status,cmdout] = dos('neato -Tplain ../output/output_m_temp.dot');
%             if status == 0
%                 textLines = textscan(cmdout, '%s','delimiter', '\n');
%                 
%                 for textLineNo = 2:length(textLines{1})
%                     tLine = sscanf( char(textLines{1}(textLineNo)),'%s %d %f %f');
%                     if( tLine(1) == 'n' && tLine(2) == 'o' && tLine(3) == 'd' && tLine(4) == 'e')
%                         k = find(AVAILABLE_IDs == tLine(5) )+1;
%                         NODE_POSITION_ID_XY(k-1,:,timeIndexNo_for_nodePositionXY) = tLine(5:7)';
%                         if tLine(5) == CENTER_ON_ID
%                             k_center_id = k;
%                             if CENTER_ON_ID ~= 0
%                                 CENTERING_OFFSET_XY = NODE_POSITION_ID_XY(k_center_id-1,2:3,timeIndexNo_for_nodePositionXY);
%                             end
%                         end
%                     end
%                 end
%                 
%                 if CENTER_ON_ID ~= 0 && sum(CENTERING_OFFSET_XY) ~= 0
%                     for i_id = 1:size(NODE_POSITION_ID_XY,1)
%                         if NODE_POSITION_ID_XY(i_id,1,timeIndexNo_for_nodePositionXY) ~= 0
%                             NODE_POSITION_ID_XY(i_id,2:3,timeIndexNo_for_nodePositionXY) = NODE_POSITION_ID_XY(i_id,2:3,timeIndexNo_for_nodePositionXY) - CENTERING_OFFSET_XY;
%                         end
%                     end
%                 end
%                 
%             end
%         case 1 % Use multidimensional scaling for placing nodes
%             if timeIndexNo == xstart_index
%                 NODE_POSITION_ID_XY(:,:,timeIndexNo_for_nodePositionXY) = mdsLayout(GRAPH_EDGES_M_FILT(timeIndexNo,:), LINKS, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
%                 k_center_id = find(NODE_POSITION_ID_XY(:,1,1) == CENTER_ON_ID);
%             else
%                 NODE_POSITION_ID_XY(:,:,timeIndexNo_for_nodePositionXY) = mdsLayout(GRAPH_EDGES_M_FILT(timeIndexNo,:), LINKS, 1+LINKS_UNRELIABLITY(timeIndexNo,:),NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY-1));
%             end
%             
%             if size(k_center_id,1) == 1
%                 if CENTER_ON_ID ~= 0
%                     CENTERING_OFFSET_XY = NODE_POSITION_ID_XY(k_center_id,2:3,timeIndexNo_for_nodePositionXY);
%                     NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY) = NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY) - [ones(size(NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(1), ones(size(NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(2)];
%                 end
%             end
%             
%         case 2 % Use mesh relaxation for placing nodes
%                   
%             if timeIndexNo == xstart_index
%                 NODE_POSITION_ID_XY(:,:,timeIndexNo_for_nodePositionXY) = meshRelaxationLayout(GRAPH_EDGES_M_FILT(timeIndexNo,:), LINKS, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
%                 k_center_id = find(NODE_POSITION_ID_XY(:,1,1) == CENTER_ON_ID);
%             else
%                 NODE_POSITION_ID_XY(:,:,timeIndexNo_for_nodePositionXY) = meshRelaxationLayout(GRAPH_EDGES_M_FILT(timeIndexNo,:), LINKS, 1+LINKS_UNRELIABLITY(timeIndexNo,:),NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY-1));
%             end
%             
%             if size(k_center_id,1) == 1
%                 if CENTER_ON_ID ~= 0
%                     CENTERING_OFFSET_XY = NODE_POSITION_ID_XY(k_center_id,2:3,timeIndexNo_for_nodePositionXY);
%                     NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY) = NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY) - [ones(size(NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(1), ones(size(NODE_POSITION_ID_XY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(2)];
%                 end
%             end
%         otherwise
%             error('Select a valid value for LAYOUT_ALGORITHM!');
%     end
%     
%     timeIndexNo_for_nodePositionXY = timeIndexNo_for_nodePositionXY + 1;
%     
%     if timeIndexNo > nextPercentPlotIndex
%         nextPercentPlotIndex = nextPercentPlotIndex + (xstop_index-xstart_index)/100;
%         for s=1:(length(str))
%             fprintf('\b');
%         end
%         str = sprintf('%.2f percent done...\n', (timeIndexNo-xstart_index)/(xstop_index-xstart_index)*100);
%         fprintf(str);
%     end
%     
% end
% for s=1:(length(str))
%     fprintf('\b');
% end
% fprintf('100 percent done...\n');
% fprintf('Done!\n\n');
% 
error('If this file was usefull select it all and remove the first level of comments and this line!!!!');