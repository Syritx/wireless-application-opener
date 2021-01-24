using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;
using System.Text;
using System.Diagnostics;

using System.Collections.Generic;

namespace wireless_desktop {

    class Server {
        
        Socket serverSocket;
        List<Socket> clientSockets = new List<Socket>();

        bool[] places = {
            false,
            false
        };

        public Server(IPAddress iP, int port) {
            serverSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint iPEndPoint = new IPEndPoint(iP, port);
            serverSocket.Bind(iPEndPoint);
            serverSocket.Listen(5);

            System.Console.WriteLine(iP.ToString());

            ReceiveAndAcceptClients();
        }

        void LocalClientThread(Socket client) {
            bool isConnected = true;
            int id = 0;

            for (int i = 0; i < places.Length; i++) {
                if (places[i] == false) {
                    places[i] = true;
                    id = i+1;
                    break;
                }
            }
            if (id == 0) isConnected = false;

            while (isConnected) {

                byte[] bytes = new byte[2048];
                client.Receive(bytes);

                string command = Encoding.UTF8.GetString(bytes);
                System.Console.WriteLine(command);

                if (command.StartsWith("disconnect_ed")) {
                    System.Console.WriteLine("disconnected");
                    isConnected = false;
                    places[id-1] = false;
                    break;
                }

                if (command.StartsWith("[open_appl]:")) {
                    string app = command.Split("[open_appl]:")[1];
                    string applicationFile = app.EndsWith(".app") ? app : app+".app";
                    System.Console.WriteLine(applicationFile);

                    // opens [applicationFile] application on Mac
                    Process external = new Process();
                    external.StartInfo.FileName = "/Applications/"+applicationFile;
                    external.StartInfo.UseShellExecute = true;
                    external.Start();
                    external.WaitForExit();
                }
            }
            client.Close();
        }

        void SendToDesignatedClient(int id, string message) {
            try {
                clientSockets[id].Send(Encoding.UTF8.GetBytes(message));
                System.Console.WriteLine("sent");
            }
            catch(System.Exception e) {}
        }

        void ReceiveAndAcceptClients() {
            while (true) {
                Socket client = serverSocket.Accept();
                clientSockets.Add(client);
                System.Console.WriteLine("found connection");
                Task.Run(() => LocalClientThread(client));
            }
        }
    }
}