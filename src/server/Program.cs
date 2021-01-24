using System;
using System.Net;

namespace wireless_desktop
{
    class Program
    {
        static void Main(string[] args)
        {
            new Server(Dns.GetHostEntry(Dns.GetHostName()).AddressList[0], 6060);
        }
    }
}
