class RoomsController < ApplicationController
	#Dokumentacja OpenTok https://github.com/opentok/Opentok-Ruby-SDK/blob/master/doc/reference.md
	# Metoda config_opentok - wywoływana jest jako pierwsza
	before_filter :config_opentok,:except => [:index]
  before_filter :authenticate_user!, :except =>[:index]
  def index
	#Przypisanie do zmiennych instancyjnych
	#@rooms - lista pokoi
    #@new_room - stworzenie nowego pokoju

if current_user
     @sheets = current_user.email
      sheets1 = current_user.id
     user_in_room = User.find(sheets1)
     user_in_room.room_id = nil
     user_in_room.save
   else

     redirect_to new_user_session_path, notice: 'You are not logged in.'
   end



	@rooms = Room.where(:public => true).order("created_at DESC")
    @new_room = Room.new
#@user = User.find(params[:current_user.id])

  end

    def create
    params.permit! #nie można podmieniać czegoś tam...


#Przypisanie do zmiennej session obiektu Session (oraz sessionID)
#zwroconej z metody create session
#request.remote_addr - adres IP, ktory jest argumentem
#create_session - wykorzystywany 
    session = @opentok.create_session request.remote_addr
    params[:room][:sessionId] = session.session_id

    @new_room = Room.new(params[:room])

    respond_to do |format|
      if @new_room.save
        format.html { redirect_to("/party/"+@new_room.id.to_s) }
      else
        format.html { render :controller => 'rooms',
          :action => "index" }
      end
    end
  end

def destroy
Room.find(params[:id]).destroy
respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
    flash[:success] = "User deleted."


end

  def party
    @current_user_chat = current_user.email
       @room = Room.find(params[:id])
    current_room = Room.find(params[:id])
    if current_user
     sheets = current_user.id
     user_in_room = User.find(sheets)
     user_in_room.room_id = current_room.id
     user_in_room.save
     
   elsif current_user.admin?
  role = OpenTok::RoleConstants::MODERATOR
else
     redirect_to new_user_session_path, notice: 'You are not logged in.'
   end

  @all_user = current_room.users
   


  	 @room = Room.find(params[:id])
role = OpenTok::RoleConstants::MODERATOR
connection_data = current_user.id
@tok_token = @opentok.generate_token :session_id =>@room.sessionId, :role => role, :connection_data => connection_data.to_s
    #dobry  @tok_token = @opentok.generate_token :session_id =>@room.sessionId  
  end
  #Inicjacja obiektu OpenTokSDK 
  def config_opentok
  		api_key= '44727722'
  		api_secret = '29e97866780941ea936106816a02ccf53c02a704'
  	if @opentok.nil?
  	#Konstruktor z ApiKey, ApiSecret w celu stworzenia sesji OpenTok 
     @opentok = OpenTok::OpenTokSDK.new api_key,api_secret
    end
  end
end
